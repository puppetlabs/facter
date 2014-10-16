#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>

using namespace std;
using namespace rapidjson;
using namespace YAML;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.value.map"

namespace facter { namespace facts {

    map_value::map_value(map_value&& other)
    {
        *this = std::move(other);
    }

    map_value& map_value::operator=(map_value&& other)
    {
        value::operator=(static_cast<value&&>(other));
        if (this != &other) {
            _elements = std::move(other._elements);
        }
        return *this;
    }

    void map_value::add(string name, unique_ptr<value> value)
    {
        if (!value) {
            LOG_DEBUG("null value cannot be added to map.");
            return;
        }

        _elements.emplace(move(name), move(value));
    }

    bool map_value::empty() const
    {
        return _elements.empty();
    }

    size_t map_value::size() const
    {
        return _elements.size();
    }

    void map_value::each(function<bool(string const&, value const*)> func) const
    {
        for (auto const& kvp : _elements) {
            if (!func(kvp.first, kvp.second.get())) {
                break;
            }
        }
    }

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
            rapidjson::Value child;
            kvp.second->to_json(allocator, child);
            value.AddMember(kvp.first.c_str(), child, allocator);
        }
    }

    ostream& map_value::write(ostream& os, bool quoted, unsigned int level) const
    {
        if (_elements.empty()) {
            os << "{}";
            return os;
        }

        // Write out the elements in the map
        os << "{\n";
        bool first = true;
        for (auto const& kvp : _elements) {
            if (first) {
                first = false;
            } else {
                os << ",\n";
            }
            fill_n(ostream_iterator<char>(os), level * 2, ' ');
            os << kvp.first << " => ";
            kvp.second->write(os, true /* always quote strings in a map */, level + 1);
        }
        os << "\n";
        fill_n(ostream_iterator<char>(os), (level > 0 ? (level - 1) : 0) * 2, ' ');
        os << "}";
        return os;
    }

    Emitter& map_value::write(Emitter& emitter) const
    {
        emitter << BeginMap;
        for (auto const& kvp : _elements) {
            emitter << Key << kvp.first << YAML::Value;
            kvp.second->write(emitter);
        }
        emitter << EndMap;
        return emitter;
    }

}}  // namespace facter::facts
