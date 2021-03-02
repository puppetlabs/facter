#include <internal/facts/resolvers/az_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/vm.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>
#include <leatherman/util/environment.hpp>
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
using namespace leatherman::util;

namespace facter { namespace facts { namespace resolvers {

   az_resolver::az_resolver() :
        resolver(
            "AZ",
            {
                fact::az_metadata
            })
    {
    }

#ifdef USE_CURL
    static const char* AZ_METADATA_URL = "http://169.254.169.254/metadata/instance?api-version=2020-09-01";
    static const unsigned int AZ_CONNECTION_TIMEOUT = 600;
    #ifdef HAS_LTH_GET_INT
        static const unsigned int AZ_SESSION_TIMEOUT = environment::get_int("AZ_SESSION_TIMEOUT", 5000);
    #else
        static const unsigned int AZ_SESSION_TIMEOUT = 5000;
    #endif
#endif

    struct json_event_handler
    {
        explicit json_event_handler(map_value& root) :
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
            add_value(make_value<string_value>(s));
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

    void az_resolver::resolve(collection& facts)
    {
        auto virtualization = facts.get<string_value>(fact::virtualization);
        if (!virtualization || virtualization->value() != vm::hyperv) {
            LOG_DEBUG("not running under a Azure instance.");
            return;
        }

#ifndef USE_CURL
        LOG_INFO("Azure instance metadata fact is unavailable: facter was built without libcurl support.");
        return;
#else
        LOG_DEBUG("querying Azure metadata.");

        try
        {
            lth_curl::request req(AZ_METADATA_URL);
            req.add_header("Metadata", "true");
            req.connection_timeout(AZ_CONNECTION_TIMEOUT);
            req.timeout(AZ_SESSION_TIMEOUT);

            lth_curl::client cli;
            auto response = cli.get(req);
            if (response.status_code() != 200) {
                LOG_DEBUG("request for {1} returned a status code of {2}.", req.url(), response.status_code());
                return;
            }

            auto data = make_value<map_value>();

            Reader reader;
            StringStream ss(response.body().c_str());
            json_event_handler handler(*data);
            auto result = reader.Parse(ss, handler);
            if (!result) {
                LOG_ERROR("failed to parse Azure metadata: {1}.", GetParseError_En(result.Code()));
                return;
            }

            if (!data->empty()) {
                facts.add(fact::az_metadata, move(data));
            }
        } catch (lth_curl::http_request_exception& ex) {
            LOG_DEBUG("Azure instance metadata fact is unavailable: not running under an Azure instance or Azure is not responding in a timely manner.");
            LOG_TRACE("Azure metadata request failed: {1}", ex.what());
            return;
        } catch (runtime_error& ex) {
            LOG_ERROR("Azure metadata request failed: {1}", ex.what());
        }
#endif
    }

    bool az_resolver::is_blockable() const {
        return true;
    }
}}}  // namespace facter::facts::resolvers

