#include <facter/facts/posix/dmi_resolver.hpp>
#include <facter/facts/fact.hpp>

using namespace std;

namespace facter { namespace facts { namespace posix {

    dmi_resolver::dmi_resolver() :
        resolver(
            "desktop management information",
            {
                fact::bios_vendor,
                fact::bios_version,
                fact::bios_release_date,
                fact::board_asset_tag,
                fact::board_manufacturer,
                fact::board_product_name,
                fact::board_serial_number,
                fact::chassis_asset_tag,
                fact::manufacturer,
                fact::product_name,
                fact::serial_number,
                fact::product_uuid,
                fact::chassis_type,
            })
    {
    }

}}}  // namespace facter::facts::posix
