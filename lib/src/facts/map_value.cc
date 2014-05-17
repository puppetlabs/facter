#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facterlib.h>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>

using namespace std;
using namespace rapidjson;
using namespace YAML;

namespace facter { namespace facts {

    value const* map_value::operator[](string const& name) const
    {
        auto it = _elements.find(name);
        if (it == _elements.end()) {
            return nullptr;
        }
        return it->second.get();
    }

    void map_value::to_json(Allocator& allocator, rapidjson::Value& value) const
    {
        value.SetObject();

        for (auto const& kvp : _elements) {
            if (!kvp.second) {
                continue;
            }
            rapidjson::Value child;
            kvp.second->to_json(allocator, child);
            value.AddMember(kvp.first.c_str(), child, allocator);
        }
    }

    void map_value::notify(string const& name, enumeration_callbacks const* callbacks) const
    {
        if (!callbacks) {
            return;
        }

        if (callbacks->map_start) {
            callbacks->map_start(name.c_str());
        }

        // Call notify on each element in the array
        for (auto const& element : _elements) {
            if (!element.second) {
                continue;
            }
            element.second->notify(element.first, callbacks);
        }

        if (callbacks->map_end) {
            callbacks->map_end();
        }
    }

    ostream& map_value::write(ostream& os) const
    {
        // Write out the elements in the map
        os << "{";
        bool first = true;
        for (auto const& kvp : _elements) {
            if (!kvp.second) {
                continue;
            }
            if (first) {
                first = false;
            } else {
                os << ", ";
            }
            os << '"' << kvp.first << "\"=>";
            bool quote = dynamic_cast<string_value const*>(kvp.second.get());
            if (quote) {
                os << '"';
            }
            os << *kvp.second;
            if (quote) {
                os << '"';
            }
        }
        os << "}";
        return os;
    }

    Emitter& map_value::write(Emitter& emitter) const
    {
        emitter << BeginMap;
        for (auto const& kvp : _elements) {
            emitter << Key << kvp.first;
            emitter << YAML::Value;
            if (!kvp.second) {
                emitter << Null;
            } else {
                emitter << *kvp.second;
            }
        }
        emitter << EndMap;
        return emitter;
    }

}}  // namespace facter::facts
