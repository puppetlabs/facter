#include <facts/string_value.hpp>

using namespace std;

namespace cfacter { namespace facts {

    string string_value::to_string() const
    {
        return _value;
    }

}}  // namespace cfacter::facts
