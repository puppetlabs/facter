#include <facter/facts/array_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facterlib.h>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>

using namespace std;
using namespace rapidjson;
using namespace YAML;

namespace facter { namespace facts {

    void array_value::to_json(Allocator& allocator, rapidjson::Value& value) const
    {
        value.SetArray();
        value.Reserve(_elements.size(), allocator);

        for (auto const& element : _elements) {
            if (!element) {
                continue;
            }

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
            if (!element) {
                continue;
            }
            element->notify({}, callbacks);
        }

        if (callbacks->array_end) {
            callbacks->array_end();
        }
    }

    ostream& array_value::write(ostream& os) const
    {
        // Write out the elements in the array
        os << "[";
        bool first = true;
        for (auto const& element : _elements) {
            if (!element) {
                continue;
            }
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
            if (!element) {
                continue;
            }
            emitter << *element;
        }
        emitter << EndSeq;
        return emitter;
    }

}}  // namespace facter::facts
