#include <facts/array_value.hpp>
#include <sstream>

using namespace std;

namespace cfacter { namespace facts {

    string array_value::to_string() const
    {
        ostringstream result;

        // Write out the elements in the array
        result << "[";
        bool first = true;
        for (auto const& element : _elements) {
            if (!first) {
                result << ", ";
            } else {
                first = true;
            }
            result << element->to_string();
        }
        result << "]";
        return result.str();
    }

}}  // namespace cfacter::facts
