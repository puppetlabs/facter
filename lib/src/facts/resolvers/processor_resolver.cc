#include <internal/facts/resolvers/processor_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/util/string.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace resolvers {

    processor_resolver::processor_resolver() :
        resolver(
            "processor",
            {
                fact::processors,
                fact::processor_count,
                fact::physical_processor_count,
                fact::hardware_isa,
            },
            {
                string("^") + fact::processor + "[0-9]+$",
            })
    {
    }

    void processor_resolver::resolve(collection& facts, set<string> const& blocklist)
    {
        auto data = collect_data(facts);

        auto cpus = make_value<map_value>();

        if (!data.isa.empty()) {
            facts.add(fact::hardware_isa, make_value<string_value>(data.isa, true));
            cpus->add("isa", make_value<string_value>(move(data.isa)));
        }

        if (data.logical_count > 0) {
            facts.add(fact::processor_count, make_value<integer_value>(data.logical_count, true));
            cpus->add("count", make_value<integer_value>(data.logical_count));
        }

        if (data.physical_count > 0) {
            facts.add(fact::physical_processor_count, make_value<integer_value>(data.physical_count, true));
            cpus->add("physicalcount", make_value<integer_value>(data.physical_count));
        }

        if (data.speed > 0) {
            cpus->add("speed", make_value<string_value>(frequency(data.speed)));
        }

        auto models = make_value<array_value>();
        int processor = 0;
        for (auto& model : data.models) {
            facts.add(fact::processor + to_string(processor++), make_value<string_value>(model, true));
            models->add(make_value<string_value>(move(model)));
        }

        if (!models->empty()) {
            cpus->add("models", move(models));
        }

        if (!cpus->empty()) {
            facts.add(fact::processors, move(cpus));
        }
    }

}}}  // namespace facter::facts::resolvers
