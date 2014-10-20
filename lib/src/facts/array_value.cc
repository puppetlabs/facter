#include <facter/facts/array_value.hpp>
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
#define LOG_NAMESPACE "facts.value.array"

namespace facter { namespace facts {

    array_value::array_value(array_value&& other)
    {
        *this = std::move(other);
    }

    array_value& array_value::operator=(array_value&& other)
    {
        value::operator=(static_cast<value&&>(other));
        if (this != &other) {
            _elements = std::move(other._elements);
        }
        return *this;
    }

    void array_value::add(unique_ptr<value> value)
    {
        if (!value) {
            LOG_DEBUG("null value cannot be added to array.");
            return;
        }

        _elements.emplace_back(move(value));
    }

    bool array_value::empty() const
    {
        return _elements.empty();
    }

    size_t array_value::size() const
    {
        return _elements.size();
    }

    void array_value::each(function<bool(value const*)> func) const
    {
        for (auto const& element : _elements) {
            if (!func(element.get())) {
                break;
            }
        }
    }

    void array_value::to_json(Allocator& allocator, rapidjson::Value& value) const
    {
        value.SetArray();
        value.Reserve(_elements.size(), allocator);

        for (auto const& element : _elements) {
            rapidjson::Value child;
            element->to_json(allocator, child);
            value.PushBack(child, allocator);
        }
    }

    value const* array_value::operator[](size_t i) const
    {
        if (i >= _elements.size()) {
            return nullptr;
        }
        return _elements[i].get();
    }

    ostream& array_value::write(ostream& os, bool quoted, unsigned int level) const
    {
        if (_elements.empty()) {
            os << "[]";
            return os;
        }

        // Write out the elements in the array
        os << "[\n";
        bool first = true;
        for (auto const& element : _elements) {
            if (first) {
                first = false;
            } else {
                os << ",\n";
            }
            fill_n(ostream_iterator<char>(os), level * 2, ' ');
            element->write(os, true /* always quote strings in an array */, level + 1);
        }
        os << "\n";
        fill_n(ostream_iterator<char>(os), (level > 0 ? (level - 1) : 0) * 2, ' ');
        os << "]";
        return os;
    }

    Emitter& array_value::write(Emitter& emitter) const
    {
        emitter << BeginSeq;
        for (auto const& element : _elements) {
            element->write(emitter);
        }
        emitter << EndSeq;
        return emitter;
    }

}}  // namespace facter::facts
