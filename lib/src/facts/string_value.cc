#include <facter/facts/string_value.hpp>

using namespace std;

namespace facter { namespace facts {

    string string_value::to_string() const
    {
        return _value;
    }

}}  // namespace facter::facts
