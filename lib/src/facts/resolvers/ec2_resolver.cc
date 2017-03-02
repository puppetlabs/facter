#include <internal/facts/resolvers/ec2_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <facter/util/string.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <set>

#ifdef USE_CURL
#include <leatherman/curl/client.hpp>
namespace lth_curl = leatherman::curl;
#endif

using namespace std;
using namespace leatherman::util;

namespace facter { namespace facts { namespace resolvers {

    ec2_resolver::ec2_resolver() :
        resolver(
            "EC2",
            {
                fact::ec2_metadata,
                fact::ec2_userdata
            })
    {
    }

#ifdef USE_CURL
    static const char* EC2_METADATA_ROOT_URL = "http://169.254.169.254/latest/meta-data/";
    static const char* EC2_USERDATA_ROOT_URL = "http://169.254.169.254/latest/user-data/";
    static const unsigned int EC2_CONNECTION_TIMEOUT = 200;
    static const unsigned int EC2_SESSION_TIMEOUT = 5000;

    static void query_metadata_value(lth_curl::client& cli, map_value& value, string const& url, string const& name, string const& http_langs)
    {
        lth_curl::request req(url + name);
        req.connection_timeout(EC2_CONNECTION_TIMEOUT);
        req.timeout(EC2_SESSION_TIMEOUT);
        if (!http_langs.empty())
            req.add_header("Accept-Language", http_langs);

        auto response = cli.get(req);
        if (response.status_code() != 200) {
            LOG_DEBUG("request for {1} returned a status code of {2}.", req.url(), response.status_code());
            return;
        }

        auto body = response.body();
        boost::trim(body);

        value.add(name, make_value<string_value>(move(body)));
    }

    static void query_metadata(lth_curl::client& cli, map_value& value, string const& url, string const& http_langs)
    {
        // Stores the metadata names to filter out
        static set<string> filter = {
            "security-credentials/"
        };

        lth_curl::request req(url);
        req.connection_timeout(EC2_CONNECTION_TIMEOUT);
        req.timeout(EC2_SESSION_TIMEOUT);
        if (!http_langs.empty())
            req.add_header("Accept-Language", http_langs);

        auto response = cli.get(req);
        if (response.status_code() != 200) {
            LOG_DEBUG("request for {1} returned a status code of {2}.", req.url(), response.status_code());
            return;
        }
        util::each_line(response.body(), [&](string& name) {
            if (name.empty()) {
                return true;
            }

            static boost::regex array_regex("^(\\d+)=.*$");

            string index;
            if (re_search(name, array_regex, &index)) {
                name = index + "/";
            }

            // Check the filter for this name
            if (filter.count(name) != 0) {
                return true;
            }

            // If the name does not end with a '/', then it is a key name; request the value
            if (name.back() != '/') {
                query_metadata_value(cli, value, url, name, http_langs);
                return true;
            }

            // Otherwise, this is a category; recurse down it
            auto child = make_value<map_value>();
            query_metadata(cli, *child, url + name, http_langs);
            trim_right_if(name, boost::is_any_of("/"));
            value.add(move(name), move(child));
            return true;
        });
    }
#endif

    void ec2_resolver::resolve(collection& facts)
    {
#ifndef USE_CURL
        LOG_INFO("EC2 facts are unavailable: facter was built without libcurl support.");
        return;
#else
        auto virtualization = facts.get<string_value>(fact::virtualization);
        if (!virtualization || (virtualization->value() != vm::kvm && !boost::starts_with(virtualization->value(), "xen"))) {
            LOG_DEBUG("EC2 facts are unavailable: not running under an EC2 instance.");
            return;
        }

        LOG_DEBUG("querying EC2 instance metadata at {1}.", EC2_METADATA_ROOT_URL);

        lth_curl::client cli;
        auto metadata = make_value<map_value>();

        try
        {
            query_metadata(cli, *metadata, EC2_METADATA_ROOT_URL, http_langs());

            if (!metadata->empty()) {
                facts.add(fact::ec2_metadata, move(metadata));
            }
        }
        catch (lth_curl::http_request_exception& ex) {
            if (ex.req().url() == EC2_METADATA_ROOT_URL) {
                // The very first query failed; most likely not an EC2 instance
                LOG_DEBUG("EC2 facts are unavailable: not running under an EC2 instance or EC2 is not responding in a timely manner.");
                LOG_TRACE("EC2 metadata request failed: {1}", ex.what());
                return;
            }
            LOG_ERROR("EC2 metadata request failed: {1}", ex.what());
        }
        catch (runtime_error& ex) {
            LOG_ERROR("EC2 metadata request failed: {1}", ex.what());
        }

        LOG_DEBUG("querying EC2 instance user data at {1}.", EC2_USERDATA_ROOT_URL);

        try {
            lth_curl::request req(EC2_USERDATA_ROOT_URL);
            req.connection_timeout(EC2_CONNECTION_TIMEOUT);
            req.timeout(EC2_SESSION_TIMEOUT);
            if (!http_langs().empty())
                req.add_header("Accept-Language", http_langs());

            auto response = cli.get(req);
            if (response.status_code() != 200) {
                LOG_DEBUG("request for {1} returned a status code of {2}.", req.url(), response.status_code());
                return;
            }

            facts.add(fact::ec2_userdata, make_value<string_value>(response.body()));
        } catch (runtime_error& ex) {
            LOG_ERROR("EC2 user data request failed: {1}", ex.what());
        }
#endif
    }

    bool ec2_resolver::is_blockable() const {
        return true;
    }

}}}  // namespace facter::facts::resolvers
