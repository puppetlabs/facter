#include <facter/facts/array_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/facterlib.h>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>

using namespace std;
using namespace rapidjson;
using namespace YAML;

LOG_DECLARE_NAMESPACE("facts.value.array");

namespace facter { namespace facts {

    void array_value::add(unique_ptr<value>&& value)
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

    void array_value::notify(string const& name, enumeration_callbacks const* callbacks) const
    {
        if (!callbacks) {
            return;
        }

        if (callbacks->array_start) {
            callbacks->array_start(name.c_str());
        }

        // Call notify on each element in the array
        for (auto const& element : _elements) {
            element->notify({}, callbacks);
        }

        if (callbacks->array_end) {
            callbacks->array_end();
        }
    }

    value const* array_value::operator[](size_t i) const
    {
        return _elements.at(i).get();
    }

    ostream& array_value::write(ostream& os) const
    {
        // Write out the elements in the array
        os << "[";
        bool first = true;
        for (auto const& element : _elements) {
            if (first) {
                first = false;
            } else {
                os << ", ";
            }
            bool quote = dynamic_cast<string_value const*>(element.get());
            if (quote) {
                os << '"';
            }
            os << *element;
            if (quote) {
                os << '"';
            }
        }
        os << "]";
        return os;
    }

    Emitter& array_value::write(Emitter& emitter) const
    {
        emitter << BeginSeq;
        for (auto const& element : _elements) {
            emitter << *element;
        }
        emitter << EndSeq;
        return emitter;
    }

}}  // namespace facter::facts
