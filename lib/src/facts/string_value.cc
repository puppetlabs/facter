#include <facter/facts/string_value.hpp>
#include <rapidjson/document.h>

using namespace std;
using namespace rapidjson;

namespace facter { namespace facts {

    void string_value::to_json(Allocator& allocator, Value& value) const
    {
        value.SetString(_value.c_str(), _value.size());
    }

    ostream& string_value::write(ostream& os) const
    {
        os << _value;
        return os;
    }

}}  // namespace facter::facts
