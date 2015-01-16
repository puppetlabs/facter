#include <facter/facts/osx/dmi_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <sys/sysctl.h>

using namespace std;

namespace facter { namespace facts { namespace osx {

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;

        int mib[] = { CTL_HW, HW_MODEL };
        size_t length = 0;

        // OSX only supports the product name
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), nullptr, &length, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl failed: %1% (%2%): DMI facts are unavailable.", strerror(errno), errno);
            return result;
        }

        vector<char> model_name(length);
        if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), model_name.data(), &length, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl failed: %1% (%2%): DMI facts are unavailable.", strerror(errno), errno);
            return result;
        }

        result.product_name = model_name.data();
        return result;
    }

}}}  // namespace facter::facts::osx
