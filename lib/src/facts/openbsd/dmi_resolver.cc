#include <internal/facts/openbsd/dmi_resolver.hpp>
#include <leatherman/logging/logging.hpp>

#include <sys/sysctl.h>

using namespace std;

namespace facter { namespace facts { namespace openbsd {

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;
        result.bios_vendor = sysctl_lookup(HW_VENDOR);
        result.uuid = sysctl_lookup(HW_UUID);
        result.serial_number = sysctl_lookup(HW_SERIALNO);
        result.product_name = sysctl_lookup(HW_PRODUCT);
        result.bios_version = sysctl_lookup(HW_VERSION);

        return result;
    }

    string dmi_resolver::sysctl_lookup(int mib_2)
    {
        int mib[2];
        size_t len;
        char value[BUFSIZ];

        mib[0] = CTL_HW;
        mib[1] = mib_2;
        len = sizeof(value) - 1;

        if (sysctl(mib, 2, &value, &len, nullptr, 0) == -1) {
            LOG_DEBUG("sysctl_lookup failed: {1} ({2}).", strerror(errno), errno);
            return "";
        }

        return value;
    }

} } }  // namespace facter::facts::openbsd
