#include "../../../version.h"
#include <facts/fact_map.hpp>
#include <facts/string_value.hpp>

using namespace std;

namespace cfacter { namespace facts {

    void populate_common_facts()
    {
        auto& facts = fact_map::instance();
        facts.add_fact(fact("cfacterversion", make_value<string_value>(CFACTER_VERSION)));
    }

}} // namespace cfacter::facts
