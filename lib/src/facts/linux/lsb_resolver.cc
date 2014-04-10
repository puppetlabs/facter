#include <facts/fact_map.hpp>
#include <facts/linux/lsb_resolver.hpp>
#include <facts/string_value.hpp>
#include <execution/execution.hpp>

using namespace std;
using namespace cfacter::execution;

namespace cfacter { namespace facts { namespace linux {

    void lsb_resolver::resolve_facts(fact_map& facts)
    {
        // Resolve all lsb-related facts
        resolve_dist_id(facts);
    }

    void lsb_resolver::resolve_dist_id(fact_map& facts)
    {
        string value = execute("lsb_release", {"-i", "-s"}, { execution_options::trim_output });
        if (value.empty()) {
            return;
        }
        facts.add_fact(fact(lsb_dist_id_name, make_value<string_value>(std::move(value))));
    }

}}}  // namespace cfacter::facts::linux
