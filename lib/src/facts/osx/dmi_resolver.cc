#include <facter/facts/osx/dmi_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/logging/logging.hpp>
#include <vector>
#include <sys/types.h>
#include <sys/sysctl.h>

using namespace std;

LOG_DECLARE_NAMESPACE("facts.osx.dmi");

namespace facter { namespace facts { namespace osx {

    void dmi_resolver::resolve_facts(fact_map& facts)
    {
        // We only support getting the product name on OSX
        resolve_product_name(facts);
    }

    void dmi_resolver::resolve_product_name(fact_map& facts)
    {
        int mib[] = { CTL_HW, HW_MODEL };
        size_t length = 0;

        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), nullptr, &length, nullptr, 0) != 0) {
            LOG_DEBUG("sysctl failed: %1% (%2%): %3% fact is unavailable.", strerror(errno), errno, fact::product_name);
            return;
        }

        vector<char> model_name(length);
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), model_name.data(), &length, nullptr, 0) != 0) {
            LOG_DEBUG("sysctl failed: %1% (%2%): %3% fact is unavailable.", strerror(errno), errno, fact::product_name);
            return;
        }

        facts.add(fact::product_name, make_value<string_value>(model_name.data()));
    }

}}}  // namespace facter::facts::osx
