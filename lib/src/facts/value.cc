#include <facter/facts/value.hpp>
#include <yaml-cpp/yaml.h>

using namespace std;
using namespace YAML;

namespace facter { namespace facts {

    ostream& operator<<(ostream& os, value const& val)
    {
        return val.write(os);
    }

    Emitter& operator<<(Emitter& emitter, value const& val)
    {
        return val.write(emitter);
    }

}}  // namespace facter::facts
