#include <facter/facts/integer_value.hpp>
#include <rapidjson/document.h>
#include <boost/lexical_cast.hpp>

using namespace std;
using namespace rapidjson;
using boost::lexical_cast;
using boost::bad_lexical_cast;

namespace facter { namespace facts {

    integer_value::integer_value(string const& value)
    {
        try {
            _value = lexical_cast<int64_t>(value);
        }
        catch (const bad_lexical_cast& e) {
            // TODO: warn?
            _value = 0;
        }
    }

    void integer_value::to_json(Allocator& allocator, Value& value) const
    {
        value.SetInt64(_value);
    }

    ostream& integer_value::write(ostream& os) const
    {
        os << _value;
        return os;
    }

}}  // namespace facter::facts
