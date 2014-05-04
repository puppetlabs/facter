#include <facter/facts/array_value.hpp>
#include <rapidjson/document.h>

using namespace std;
using namespace rapidjson;

namespace facter { namespace facts {

    void array_value::to_json(Allocator& allocator, Value& value) const
    {
        value.SetArray();

        for (auto const& element : _elements) {
            if (!element) {
                continue;
            }

            Value child;
            element->to_json(allocator, child);
            value.PushBack(child, allocator);
        }
    }

    ostream& array_value::write(ostream& os) const
    {
        // Write out the elements in the array
        os << "[ ";
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
            os << *element;
        }
        os << " ]";
        return os;
    }

}}  // namespace facter::facts
