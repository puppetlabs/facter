#include <facter/facts/resolvers/ec2_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <facter/util/string.hpp>
#include <facter/util/regex.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <set>

#ifdef USE_CURL
#include <facter/http/client.hpp>
using namespace facter::http;
#endif

using namespace std;
using namespace facter::util;

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

    void query_metadata_value(client& cli, map_value& value, string const& url, string const& name)
    {
        request req(url + name);
        req.timeout(200);

        auto response = cli.get(req);
        if (response.status_code() != 200) {
            LOG_DEBUG("request for %1% returned a status code of %2%.", req.url(), response.status_code());
            return;
        }

        auto body = response.body();
        boost::trim(body);

        value.add(name, make_value<string_value>(move(body)));
    }

    void query_metadata(client& cli, map_value& value, string const& url)
    {
        // Stores the metadata names to filter out
        static set<string> filter = {
            "security-credentials/"
        };

        request req(url);
        req.timeout(200);

        auto response = cli.get(req);
        if (response.status_code() != 200) {
            LOG_DEBUG("request for %1% returned a status code of %2%.", req.url(), response.status_code());
            return;
        }
        util::each_line(response.body(), [&](string& name) {
            if (name.empty()) {
                return true;
            }

            static re_adapter array_regex("^(\\d+)=.*$");

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
                query_metadata_value(cli, value, url, name);
                return true;
            }

            // Otherwise, this is a category; recurse down it
            auto child = make_value<map_value>();
            query_metadata(cli, *child, url + name);
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

        LOG_DEBUG("querying EC2 instance metadata at %1%.", EC2_METADATA_ROOT_URL);

        client cli;
        auto metadata = make_value<map_value>();

        try
        {
            query_metadata(cli, *metadata, EC2_METADATA_ROOT_URL);

            if (!metadata->empty()) {
                facts.add(fact::ec2_metadata, move(metadata));
            }
        }
        catch (http_request_exception& ex) {
            if (ex.req().url() == EC2_METADATA_ROOT_URL) {
                // The very first query failed; most likely not an EC2 instance
                LOG_DEBUG("EC2 facts are unavailable: not running under an EC2 instance.");
                return;
            }
            LOG_ERROR("EC2 metadata request failed: %1%", ex.what());
        }
        catch (runtime_error& ex) {
            LOG_ERROR("EC2 metadata request failed: %1%", ex.what());
        }

        LOG_DEBUG("querying EC2 instance user data at %1%.", EC2_USERDATA_ROOT_URL);

        try {
            request req(EC2_USERDATA_ROOT_URL);
            req.timeout(200);

            auto response = cli.get(req);
            if (response.status_code() != 200) {
                LOG_DEBUG("request for %1% returned a status code of %2%.", req.url(), response.status_code());
                return;
            }

            facts.add(fact::ec2_userdata, make_value<string_value>(response.body()));
        } catch (runtime_error& ex) {
            LOG_ERROR("EC2 user data request failed: %1%", ex.what());
        }
#endif
    }

}}}  // namespace facter::facts::resolvers
