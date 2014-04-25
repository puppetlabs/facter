#include "../../../version.h"
#include <facter/facts/fact_map.hpp>
#include <facter/facts/string_value.hpp>

using namespace std;

namespace facter { namespace facts {

    void populate_common_facts(fact_map& facts)
    {
        facts.add("cfacterversion", make_value<string_value>(CFACTER_VERSION));
    }

}}  // namespace facter::facts
