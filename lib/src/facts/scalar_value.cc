#include <facter/facts/scalar_value.hpp>
#include <facter/util/string.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <iomanip>

using namespace std;
using namespace facter::util;
using namespace rapidjson;
using namespace YAML;

namespace facter { namespace facts {

    template <>
    void scalar_value<string>::to_json(Allocator& allocator, rapidjson::Value& value) const
    {
        value.SetString(_value.c_str(), _value.size());
    }

    template <>
    void scalar_value<int64_t>::to_json(Allocator& allocator, rapidjson::Value& value) const
    {
        value.SetInt64(_value);
    }

    template <>
    void scalar_value<bool>::to_json(Allocator& allocator, rapidjson::Value& value) const
    {
        value.SetBool(_value);
    }

    template <>
    void scalar_value<double>::to_json(Allocator& allocator, rapidjson::Value& value) const
    {
        value.SetDouble(_value);
    }

    template <>
    Emitter& scalar_value<string>::write(Emitter& emitter) const
    {
        if (needs_quotation(_value)) {
            emitter << DoubleQuoted;
        }
        emitter << _value;
        return emitter;
    }

    template <>
    ostream& scalar_value<bool>::write(ostream& os, bool quoted, unsigned int level) const
    {
        os << boolalpha << _value << noboolalpha;
        return os;
    }

    template <>
    ostream& scalar_value<string>::write(ostream& os, bool quoted, unsigned int level) const
    {
        if (quoted) {
            os << '"';
        }
        os << _value;
        if (quoted) {
            os << '"';
        }
        return os;
    }

    template struct scalar_value<string>;
    template struct scalar_value<int64_t>;
    template struct scalar_value<bool>;
    template struct scalar_value<double>;

}}  // namespace facter::facts
