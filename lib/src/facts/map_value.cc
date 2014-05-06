#include <facter/facts/map_value.hpp>
#include <rapidjson/document.h>

using namespace std;
using namespace rapidjson;

namespace facter { namespace facts {

    value const* map_value::operator[](string const& name) const
    {
        auto it = _elements.find(name);
        if (it == _elements.end()) {
            return nullptr;
        }
        return it->second.get();
    }

    void map_value::to_json(Allocator& allocator, Value& value) const
    {
        value.SetObject();

        for (auto const& kvp : _elements) {
            if (!kvp.second) {
                continue;
            }

            Value child;
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

}}  // namespace facter::facts
