#include <internal/facts/external/json_resolver.hpp>
#include <internal/util/scoped_file.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>
#include <rapidjson/reader.h>
#include <rapidjson/filereadstream.h>
#include <rapidjson/error/en.h>
#include <boost/algorithm/string.hpp>
#include <stack>
#include <tuple>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace rapidjson;

namespace facter { namespace facts { namespace external {

    // Helper event handler for parsing JSON data
    struct json_event_handler
    {
        explicit json_event_handler(collection& facts) :
            _initialized(false),
            _facts(facts)
        {
        }

        bool Null()
        {
            check_initialized();

            // Ignore this fact as values cannot be null
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
            Int64(static_cast<uint64_t>(i));
            return true;
        }

        bool Uint(unsigned int i)
        {
            Int64(static_cast<uint64_t>(i));
            return true;
        }

        bool Int64(int64_t i)
        {
            add_value(make_value<integer_value>(i));
            return true;
        }

        bool Uint64(uint64_t i)
        {
            Int64(static_cast<uint64_t>(i));
            return true;
        }

        bool Double(double d)
        {
            add_value(make_value<double_value>(d));
            return true;
        }

        bool String(char const* str, SizeType length, bool copy)
        {
            add_value(make_value<string_value>(string(str, length)));
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

            // If the stack is empty, just add it as a top-level fact
            if (_stack.empty()) {
                if (_key.empty()) {
                    throw external::external_fact_exception(_("expected non-empty key in object."));
                }
                boost::to_lower(_key);
                _facts.add_external(move(_key), move(val));
                return;
            }

            // If there's an array or map on the stack, add the value as an element
            auto& top = _stack.top();
            auto& current = get<1>(top);
            auto array = dynamic_cast<array_value*>(current.get());
            if (array) {
                array->add(move(val));
                return;
            }
            auto map = dynamic_cast<map_value*>(current.get());
            if (map) {
                if (_key.empty()) {
                    throw external::external_fact_exception(_("expected non-empty key in object."));
                }
                map->add(move(_key), move(val));
            }
        }

        void check_initialized() const
        {
            if (!_initialized) {
                throw external::external_fact_exception(_("expected document to contain an object."));
            }
        }

        bool _initialized;
        collection& _facts;
        string _key;
        stack<tuple<string, unique_ptr<value>>> _stack;
    };

    void json_resolver::resolve(collection& facts) const
    {
        LOG_DEBUG("resolving facts from JSON file \"{1}\".", _path);

        // Open the file
        // We used a scoped_file here because rapidjson expects a FILE*
        scoped_file file(_path, "r");
        if (file == nullptr) {
            throw external_fact_exception(_("file could not be opened."));
        }

        // Use the existing FileStream class
        char buffer[4096];
        FileReadStream stream(file, buffer, sizeof(buffer));

        // Parse the file and report any errors
        Reader reader;
        json_event_handler handler(facts);
        auto result = reader.Parse(stream, handler);
        if (!result) {
            throw external_fact_exception(GetParseError_En(result.Code()));
        }

        LOG_DEBUG("completed resolving facts from JSON file \"{1}\".", _path);
    }

}}}  // namespace facter::facts::external
