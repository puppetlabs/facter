#include "../../../version.h"
#include <facts/fact_map.hpp>
#include <facts/string_value.hpp>

using namespace std;

namespace cfacter { namespace facts {

    void populate_common_facts(fact_map& facts)
    {
        facts.add("cfacterversion", make_value<string_value>(CFACTER_VERSION));
    }

}}  // namespace cfacter::facts
