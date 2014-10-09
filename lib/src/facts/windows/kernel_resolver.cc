#include <facter/facts/windows/kernel_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/fact.hpp>
#include <facter/logging/logging.hpp>

namespace facter { namespace facts { namespace windows {

    kernel_resolver::data kernel_resolver::collect_data(collection& facts)
    {
        // On Windows, these are identical to the operating system facts.
        data result;

        auto name = facts.get<string_value>(fact::operating_system);
        if (name) {
            result.name = name->value();
        }

        auto release = facts.get<string_value>(fact::operating_system_release);
        if (release) {
            result.release = release->value();
            result.version = result.release;
        }

        return result;
    }

}}}  // namespace facter::facts::windows
