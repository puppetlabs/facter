#include <facter/facts/map_value.hpp>
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

    ostream& map_value::write(ostream& os) const
    {
        // Write out the elements in the map
        os << "{ ";
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
            os << kvp.first << " => " << *kvp.second;
        }
        os << " }";
        return os;
    }

    Emitter& map_value::write(Emitter& emitter) const
    {
        emitter << BeginMap;
        for (auto const& kvp : _elements) {
            emitter << Key << kvp.first;
            emitter << YAML::Value << *kvp.second;
        }
        emitter << EndMap;
        return emitter;
    }

}}  // namespace facter::facts
