#include <facts/fact_resolver.hpp>
#include <facts/fact_map.hpp>

using namespace std;

namespace cfacter { namespace facts {

    void fact_resolver::resolve(fact_map& facts)
    {
        if (_resolving) {
            throw circular_resolution_exception("a cycle in fact resolution was detected.");
        }
        cycle_guard guard(_resolving);
        return resolve_facts(facts);
    }

}} // namespace cfacter::facts
