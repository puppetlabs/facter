#include <facter/facts/external/json_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/scoped_file.hpp>
#include <rapidjson/reader.h>
#include <rapidjson/filestream.h>
#include <boost/algorithm/string.hpp>
#include <stack>
#include <tuple>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace rapidjson;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.external.json"

namespace facter { namespace facts { namespace external {

    // Helper event handler for parsing JSON data
    struct json_event_handler
    {
        explicit json_event_handler(collection& facts) :
            _initialized(false),
            _facts(facts)
        {
        }

        void Null()
        {
            check_initialized();

            // Ignore this fact as values cannot be null
            _key.clear();
        }

        void Bool(bool b)
        {
            add_value(make_value<boolean_value>(b));
        }

        void Int(int i)
        {
            Int64(static_cast<uint64_t>(i));
        }

        void Uint(unsigned int i)
        {
            Int64(static_cast<uint64_t>(i));
        }

        void Int64(int64_t i)
        {
            add_value(make_value<integer_value>(i));
        }

        void Uint64(uint64_t i)
        {
            Int64(static_cast<uint64_t>(i));
        }

        void Double(double d)
        {
            add_value(make_value<double_value>(d));
        }

        void String(char const* s, SizeType len, bool copy)
        {
            // If the stack is empty or the top is a map and we don't have a key yet, set the key
            if ((_stack.empty() || dynamic_cast<map_value*>(get<1>(_stack.top()).get())) && _key.empty()) {
                check_initialized();
                _key = s;
                return;
            }

            add_value(make_value<string_value>(s));
        }

        void StartObject()
        {
            if (!_initialized) {
                _initialized = true;
                return;
            }

            // Push a map onto the stack
            _stack.emplace(make_tuple(move(_key), make_value<map_value>()));
        }

        void EndObject(SizeType count)
        {
            // Check to see if the stack is empty since we don't push for the top-level object
            if (_stack.empty()) {
                return;
            }

            // Pop the data off the stack
            auto top = move(_stack.top());
            _stack.pop();

            // Restore the key and add the value
            _key = move(get<0>(top));
            add_value(move(get<1>(top)));
        }

        void StartArray()
        {
            check_initialized();

            // Push an array onto the stack
            _stack.emplace(make_tuple(move(_key), make_value<array_value>()));
        }

        void EndArray(SizeType count)
        {
            // Pop the data off the stack
            auto top = move(_stack.top());
            _stack.pop();

            // Restore the key and add the value
            _key = move(get<0>(top));
            add_value(move(get<1>(top)));
        }

     private:
        template <typename T> void add_value(unique_ptr<T>&& val)
        {
            check_initialized();

            // If the stack is empty, just add it as a top-level fact
            if (_stack.empty()) {
                if (_key.empty()) {
                    throw external::external_fact_exception("expected non-empty key in object.");
                }
                boost::to_lower(_key);
                _facts.add(move(_key), move(val));
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
                    throw external::external_fact_exception("expected non-empty key in object.");
                }
                map->add(move(_key), move(val));
            }
        }

        void check_initialized()
        {
            if (!_initialized) {
                throw external::external_fact_exception("expected document to contain an object.");
            }
        }

        bool _initialized;
        collection& _facts;
        string _key;
        stack<tuple<string, unique_ptr<value>>> _stack;
    };

    bool json_resolver::can_resolve(string const& path) const
    {
        return boost::iends_with(path, ".json");
    }

    void json_resolver::resolve(string const& path, collection& facts) const
    {
        LOG_DEBUG("resolving facts from JSON file \"%1%\".", path);

        // Open the file
        // We used a scoped_file here because rapidjson expects a FILE*
        scoped_file file(path, "r");
        if (file == nullptr) {
            throw external_fact_exception("file could not be opened.");
        }

        // Use the existing FileStream class
        FileStream stream(file);

        // Parse the file and report any errors
        Reader reader;
        json_event_handler handler(facts);
        reader.Parse<0>(stream, handler);
        if (reader.HasParseError()) {
            throw external_fact_exception(reader.GetParseError());
        }

        LOG_DEBUG("completed resolving facts from JSON file \"%1%\".", path);
    }

}}}  // namespace facter::facts::external
