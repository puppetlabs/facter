#include <internal/facts/resolvers/gce_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/vm.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <rapidjson/reader.h>
#include <rapidjson/error/en.h>
#include <stack>
#include <tuple>
#include <stdexcept>

#ifdef USE_CURL
#include <leatherman/curl/client.hpp>
#include <leatherman/curl/request.hpp>
#include <leatherman/curl/response.hpp>
namespace lth_curl = leatherman::curl;
#endif

using namespace std;
using namespace rapidjson;

namespace facter { namespace facts { namespace resolvers {

#ifdef USE_CURL
    static const unsigned int GCE_CONNECTION_TIMEOUT = 1000;
    static const unsigned int GCE_SESSION_TIMEOUT = 5000;
#endif

    // Helper event handler for parsing JSON data
    struct gce_event_handler
    {
        explicit gce_event_handler(map_value& root) :
            _initialized(false),
            _root(root)
        {
        }

        bool Null()
        {
            check_initialized();
            _key.clear();
            return true;
        }

        bool Bool(bool b)
        {
            add_value(make_value<boolean_value>(b));
            return true;
        }

        bool Int(int i)
        {
            Uint64(static_cast<uint64_t>(i));
            return true;
        }

        bool Uint(unsigned int i)
        {
            Uint64(static_cast<uint64_t>(i));
            return true;
        }

        bool Int64(int64_t i)
        {
            Uint64(static_cast<uint64_t>(i));
            return true;
        }

        bool Uint64(uint64_t i)
        {
            add_value(make_value<integer_value>(i));
            return true;
        }

        bool Double(double d)
        {
            add_value(make_value<double_value>(d));
            return true;
        }

        bool String(char const* s, SizeType len, bool copy)
        {
            string value(s, len);

            // See https://cloud.google.com/compute/docs/metadata for information about these values
            if (_key == "sshKeys") {
                // The sshKeys attribute is a list of SSH keys delimited by newline characters
                // Turn this value into an array for the fact

                // Trim any whitespace off the string before splitting
                boost::trim(value);

                // Split at newlines and transform into an array value
                vector<string> keys;
                boost::split(keys, value, boost::is_any_of("\n"), boost::token_compress_on);

                auto array = make_value<array_value>();
                for (auto& key : keys) {
                    array->add(make_value<string_value>(move(key)));
                }
                add_value(move(array));
                return true;
            }
            if (_key == "image" || _key == "machineType" || _key == "zone" || _key == "network") {
                // These values are fully qualified, but we only want to display the last name
                // Therefore, use only what comes after the last / character
                auto pos = value.find_last_of('/');
                if (pos != string::npos) {
                    value = value.substr(pos + 1);
                }
            }

            add_value(make_value<string_value>(move(value)));
            return true;
        }

        bool Key(const char* str, SizeType length, bool copy)
        {
            check_initialized();
            _key = string(str, length);
            return true;
        }

        bool StartObject()
        {
            if (!_initialized) {
                _initialized = true;
                return true;
            }

            // Push a map onto the stack
            _stack.emplace(make_tuple(move(_key), make_value<map_value>()));
            return true;
        }

        bool EndObject(SizeType count)
        {
            // Check to see if the stack is empty since we don't push for the top-level object
            if (_stack.empty()) {
                return true;
            }

            // Pop the data off the stack
            auto top = move(_stack.top());
            _stack.pop();

            // Restore the key and add the value
            _key = move(get<0>(top));
            add_value(move(get<1>(top)));
            return true;
        }

        bool StartArray()
        {
            check_initialized();

            // Push an array onto the stack
            _stack.emplace(make_tuple(move(_key), make_value<array_value>()));
            return true;
        }

        bool EndArray(SizeType count)
        {
            // Pop the data off the stack
            auto top = move(_stack.top());
            _stack.pop();

            // Restore the key and add the value
            _key = move(get<0>(top));
            add_value(move(get<1>(top)));
            return true;
        }

     private:
        template <typename T> void add_value(unique_ptr<T>&& val)
        {
            check_initialized();

            value* current = nullptr;

            if (_stack.empty()) {
                current = &_root;
            } else {
                current = get<1>(_stack.top()).get();
            }

            auto map = dynamic_cast<map_value*>(current);
            if (map) {
                if (_key.empty()) {
                    throw external::external_fact_exception("expected non-empty key in object.");
                }
                map->add(move(_key), move(val));
                return;
            }
            auto array = dynamic_cast<array_value*>(current);
            if (array) {
                array->add(move(val));
                return;
            }
        }

        void check_initialized() const
        {
            if (!_initialized) {
                throw external::external_fact_exception("expected document to contain an object.");
            }
        }

        bool _initialized;
        map_value& _root;
        string _key;
        stack<tuple<string, unique_ptr<value>>> _stack;
    };

    gce_resolver::gce_resolver() :
        resolver("GCE", { fact::gce })
    {
    }

    void gce_resolver::resolve(collection& facts, set<string> const& blocklist)
    {
        auto virtualization = facts.get<string_value>(fact::virtualization);
        if (!virtualization || virtualization->value() != vm::gce) {
            LOG_DEBUG("not running under a GCE instance.");
            return;
        }
#ifndef USE_CURL
        LOG_INFO("GCE facts are unavailable: facter was built without libcurl support.");
        return;
#else
        LOG_DEBUG("querying GCE metadata.");

        try
        {
            lth_curl::request req("http://metadata/computeMetadata/v1beta1/?recursive=true&alt=json");
            req.connection_timeout(GCE_CONNECTION_TIMEOUT);
            req.timeout(GCE_SESSION_TIMEOUT);
            if (!http_langs().empty())
                req.add_header("Accept-Language", http_langs());

            lth_curl::client cli;
            auto response = cli.get(req);
            if (response.status_code() != 200) {
                LOG_DEBUG("request for %1% returned a status code of %2%.", req.url(), response.status_code());
                return;
            }

            auto data = make_value<map_value>();

            Reader reader;
            StringStream ss(response.body().c_str());
            gce_event_handler handler(*data);
            auto result = reader.Parse(ss, handler);
            if (!result) {
                LOG_ERROR("failed to parse GCE metadata: %1%.", GetParseError_En(result.Code()));
                return;
            }

            if (!data->empty()) {
                facts.add(fact::gce, move(data));
            }
        } catch (runtime_error& ex) {
            LOG_ERROR("GCE metadata request failed: %1%", ex.what());
        }
#endif
    }

}}}  // namespace facter::facts::resolvers
