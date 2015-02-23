#include <facter/facts/linux/dmi_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/file.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::util;
using namespace boost::filesystem;
namespace bs = boost::system;

namespace facter { namespace facts { namespace linux {

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;
        result.bios_vendor          = read("/sys/class/dmi/id/bios_vendor");
        result.bios_version         = read("/sys/class/dmi/id/bios_version");
        result.bios_release_date    = read("/sys/class/dmi/id/bios_date");
        result.board_asset_tag      = read("/sys/class/dmi/id/board_asset_tag");
        result.board_manufacturer   = read("/sys/class/dmi/id/board_vendor");
        result.board_product_name   = read("/sys/class/dmi/id/board_name");
        result.board_serial_number  = read("/sys/class/dmi/id/board_serial");
        result.chassis_asset_tag    = read("/sys/class/dmi/id/chassis_asset_tag");
        result.manufacturer         = read("/sys/class/dmi/id/sys_vendor");
        result.product_name         = read("/sys/class/dmi/id/product_name");
        result.serial_number        = read("/sys/class/dmi/id/product_serial");
        result.uuid                 = read("/sys/class/dmi/id/product_uuid");
        result.chassis_type         = to_chassis_description(read("/sys/class/dmi/id/chassis_type"));
        return result;
    }

    string dmi_resolver::read(std::string const& path)
    {
        bs::error_code ec;
        if (!is_regular_file(path, ec)) {
            LOG_DEBUG("%1%: %2%.", path, ec.message());
            return {};
        }

        string value;
        if (!file::read(path, value)) {
            LOG_DEBUG("%1%: file could not be read.", path);
            return {};
        }

        boost::trim(value);
        return value;
    }

}}}  // namespace facter::facts::linux
