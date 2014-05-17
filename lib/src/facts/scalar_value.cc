#include <facter/facts/scalar_value.hpp>
#include <rapidjson/document.h>

using namespace std;
using namespace rapidjson;

namespace facter { namespace facts {

    template <>
    void scalar_value<string>::to_json(Allocator& allocator, Value& value) const
    {
        value.SetString(_value.c_str(), _value.size());
    }

    template <>
    void scalar_value<int64_t>::to_json(Allocator& allocator, Value& value) const
    {
        value.SetInt64(_value);
    }

    template <>
    void scalar_value<bool>::to_json(Allocator& allocator, Value& value) const
    {
        value.SetBool(_value);
    }

    template struct scalar_value<string>;
    template struct scalar_value<int64_t>;
    template struct scalar_value<bool>;

}}  // namespace facter::facts
