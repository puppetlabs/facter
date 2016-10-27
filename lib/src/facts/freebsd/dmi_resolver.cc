#include <internal/facts/freebsd/dmi_resolver.hpp>
#include <leatherman/logging/logging.hpp>

#include <kenv.h>

using namespace std;

namespace facter { namespace facts { namespace freebsd {

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;
        result.bios_vendor = kenv_lookup("smbios.bios.vendor");
        result.bios_version = kenv_lookup("smbios.bios.version");
        result.bios_release_date = kenv_lookup("smbios.bios.reldate");
        result.uuid = kenv_lookup("smbios.system.uuid");
        result.serial_number = kenv_lookup("smbios.planar.serial");
        result.product_name = kenv_lookup("smbios.system.product");
        result.manufacturer = kenv_lookup("smbios.system.maker");

        return result;
    }

    string dmi_resolver::kenv_lookup(const char* file)
    {
        char buffer[100] = {};

        LOG_DEBUG("kenv lookup for {1}", file);
        if (kenv(KENV_GET, file, buffer, sizeof(buffer) - 1) == -1) {
            LOG_WARNING("kenv lookup for {1} failed: {2} ({3})", file, strerror(errno), errno);
            return "";
        }
        return buffer;
    }

} } }  // namespace facter::facts::freebsd
