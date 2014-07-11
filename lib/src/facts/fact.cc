#include <facter/version.h>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>

using namespace std;

namespace facter { namespace facts {

    void populate_common_facts(collection& facts)
    {
        facts.add("cfacterversion", make_value<string_value>(LIBFACTER_VERSION));
    }

}}  // namespace facter::facts
