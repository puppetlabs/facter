#include <facter/facts/value.hpp>

using namespace std;

namespace facter { namespace facts {

    ostream& operator<<(ostream& os, value const& val)
    {
        return val.write(os);
    }

}}  // namespace facter::facts
