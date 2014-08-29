#include <facter/facts/posix/processor_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/execution/execution.hpp>
#include <cstring>

using namespace std;
using namespace facter::facts;
using namespace facter::execution;

LOG_DECLARE_NAMESPACE("facts.posix.processor");

namespace facter { namespace facts { namespace posix {

    processor_resolver::processor_resolver() :
        resolver(
            "processor",
            {
                fact::processors,
                fact::processor_count,
                fact::physical_processor_count,
                fact::hardware_isa,
                fact::hardware_model,
            },
            {
                string("^") + fact::processor + "[0-9]+$",
            })
    {
    }

    void processor_resolver::resolve_facts(collection& facts)
    {
        // Resolve the hardware related facts
        struct utsname name;
        memset(&name, 0, sizeof(name));
        if (uname(&name) == -1) {
            LOG_WARNING("uname failed: %1% (%2%): %3% and %4% facts are unavailable.", strerror(errno), errno, fact::hardware_isa, fact::hardware_model);
        } else {
            resolve_hardware_model(facts, name);
            resolve_hardware_isa(facts, name);
        }

        // Resolve the architecture
        resolve_architecture(facts);

        // Resolve the processors structured fact
        resolve_structured_processors(facts);  // Must be before processors b/c several processor facts are based on this

        // Resolve the processors facts
        resolve_processors(facts);
    }

    void processor_resolver::resolve_hardware_isa(collection& facts, struct utsname const& name)
    {
        // The utsname struct doesn't have a member for "uname -p", so we need to execute
        auto result = execute("uname", { "-p" });
        if (!result.first || result.second.empty()) {
            return;
        }
        facts.add(fact::hardware_isa, make_value<string_value>(move(result.second)));
    }

    void processor_resolver::resolve_hardware_model(collection& facts, struct utsname const& name)
    {
        // There is a corresponding field for "uname -m", so use it
        string value = name.machine;
        if (value.empty()) {
            return;
        }
        facts.add(fact::hardware_model, make_value<string_value>(move(value)));
    }

    void processor_resolver::resolve_architecture(collection& facts)
    {
        // By default, use the hardware model
        auto model = facts.get<string_value>(fact::hardware_model, false);
        if (!model) {
            return;
        }
        facts.add(fact::architecture, make_value<string_value>(model->value()));
    }

    void processor_resolver::resolve_processors(collection& facts)
    {
        auto processors = facts.get<map_value>(fact::processors, false);
        if (!processors) {
            return;
        }

        auto count = processors->get<integer_value>("count");
        auto physicalcount = processors->get<integer_value>("physicalcount");
        if (count) {
            string test = to_string(count->value());
            facts.add(fact::processor_count, make_value<string_value>(to_string(count->value())));
        }

        if (physicalcount) {
            facts.add(fact::physical_processor_count, make_value<string_value>(to_string(physicalcount->value())));
        }

        auto processor_list = processors->get<array_value>("models");
        if (!processor_list) {
            return;
        }

        int length = processor_list->size();
        for (int i = 0; i < length; ++i) {
            auto description = processor_list->get<string_value>(i);
            if (!description) {
                return;
            }

            facts.add(string(fact::processor) + to_string(i), make_value<string_value>(description->value()));
        }
    }

}}}  // namespace facter::facts::posix
