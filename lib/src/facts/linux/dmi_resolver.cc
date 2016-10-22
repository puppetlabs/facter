#include <internal/facts/linux/dmi_resolver.hpp>
#include <internal/util/agent.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/execution/execution.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace boost::filesystem;
namespace bs = boost::system;
namespace lth_file = leatherman::file_util;
using namespace facter::util;
using namespace leatherman::util;

namespace facter { namespace facts { namespace linux {

    dmi_resolver::data dmi_resolver::collect_data(collection& facts)
    {
        data result;

        // Check that /sys/class/dmi exists (requires kernel 2.6.23+)
        bs::error_code ec;
        if (exists("/sys/class/dmi/", ec)) {
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
        } else {
            LOG_DEBUG("/sys/class/dmi cannot be accessed: using dmidecode to query DMI information.");

            int dmi_type = -1;
            string dmidecode = agent::which("dmidecode");
            leatherman::execution::each_line(dmidecode, [&](string& line) {
                parse_dmidecode_output(result, line, dmi_type);
                return true;
            });
        }
        return result;
    }

    void dmi_resolver::parse_dmidecode_output(data& result, string& line, int& dmi_type)
    {
        static const boost::regex dmi_section_pattern("^Handle 0x.{4}, DMI type (\\d{1,3})");

        // Stores the relevant sections; this is in order based on DMI type ID
        // Ensure there's a trailing semicolon on each entry and keep in sync with the switch statement below
        static const vector<vector<string>> sections = {
            {   // BIOS (0)
                "vendor:",
                "version:",
                "release date:",
            },
            {   // System (1)
                "manufacturer:",
                "product:",
                "product name:",
                "serial number:",
                "uuid:",
            },
            {   // Base Board (2)
                "manufacturer:",
                "product:",
                "product name:",
                "serial number:",
                "asset tag:",
            },
            {   // Chassis (3)
                "type:",
                "chassis type:",
                "asset tag:",
            }
        };

        // Check for a section header
        if (re_search(line, dmi_section_pattern, &dmi_type)) {
            return;
        }

        // Check that we're in a relevant section
        if (dmi_type < 0 || static_cast<size_t>(dmi_type) >= sections.size()) {
            return;
        }

        // Trim leading whitespace
        boost::trim_left(line);

        // Find a matching header
        auto const& headers = sections[dmi_type];
        auto it = find_if(headers.begin(), headers.end(), [&](string const& header) {
            return boost::istarts_with(line, header);
        });
        if (it == headers.end()) {
            return;
        }

        // Get the value and trim it
        string value = line.substr(it->size());
        boost::trim(value);

        // Calculate the index into the header vector
        size_t index = it - headers.begin();

        // Assign to the appropriate member
        string* member = nullptr;
        switch (dmi_type) {
            case 0: {  // BIOS information
                if (index == 0) {
                    member = &result.bios_vendor;
                } else if (index == 1) {
                    member = &result.bios_version;
                }  else if (index == 2) {
                    member = &result.bios_release_date;
                }
                break;
            }

            case 1: {  // System information
                if (index == 0) {
                    member = &result.manufacturer;
                } else if (index == 1 || index == 2) {
                    member = &result.product_name;
                } else if (index == 3) {
                    member = &result.serial_number;
                } else if (index == 4) {
                    member = &result.uuid;
                }
                break;
            }

            case 2: {  // Base board information
                if (index == 0) {
                    member = &result.board_manufacturer;
                } else if (index == 1 || index == 2) {
                    member = &result.board_product_name;
                } else if (index == 3) {
                    member = &result.board_serial_number;
                } else if (index == 4) {
                    member = &result.board_asset_tag;
                }
                break;
            }

            case 3: {  // Chassis information
                if (index == 0 || index == 1) {
                    member = &result.chassis_type;
                } else if (index == 2) {
                    member = &result.chassis_asset_tag;
                }
                break;
            }

            default:
                break;
        }

        if (member) {
            *member = std::move(value);
        }
    }

    string dmi_resolver::read(std::string const& path)
    {
        bs::error_code ec;
        if (!is_regular_file(path, ec)) {
            LOG_DEBUG("{1}: {2}.", path, ec.message());
            return {};
        }

        string value;
        if (!lth_file::read(path, value)) {
            LOG_DEBUG("{1}: file could not be read.", path);
            return {};
        }

        boost::trim(value);

        // Replace any non-printable ASCII characters with '.'
        // This mimics the behavior of dmidecode
        for (auto& c : value) {
            if (c < 32 || c == 127) {
                c = '.';
            }
        }
        return value;
    }

}}}  // namespace facter::facts::linux
