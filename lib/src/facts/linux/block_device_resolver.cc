#include <facter/facts/linux/block_device_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/string_value.hpp>
#include <facter/facts/integer_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/file.hpp>
#include <facter/util/string.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace facter::util;
using namespace boost::filesystem;
using boost::lexical_cast;
using boost::bad_lexical_cast;
namespace bs = boost::system;

LOG_DECLARE_NAMESPACE("facts.linux.blockdevices");

namespace facter { namespace facts { namespace linux {

    void block_device_resolver::resolve_facts(fact_map& facts)
    {
        static string devices_directory = "/sys/block/";

        bs::error_code ec;
        if (!is_directory(devices_directory, ec)) {
            LOG_DEBUG("%1%: %2%: block device facts are unavailable.", devices_directory, ec.message());
            return;
        }

        // Enumerate all block devices
        ostringstream devices;
        directory_iterator end;
        directory_iterator it;

        try {
            it = directory_iterator(devices_directory);
        } catch (filesystem_error& ex) {
            LOG_DEBUG("%1%: %2%: block device facts are unavailable.", devices_directory, ex.what());
            return;
        }

        for (; it != end; ++it) {
            bs::error_code ec;
            if (!is_directory(it->status())) {
                continue;
            }

            // Check for the device directory
            string device = it->path().filename().string();
            string device_directory = devices_directory + device + "/device/";
            if (!is_directory(device_directory, ec)) {
                continue;
            }

            string size_file = devices_directory + device + "/size";
            string vendor_file = device_directory + "vendor";
            string model_file = device_directory + "model";

            // Read the size of the block device
            // The size is in 512 byte sectors
            if (is_regular_file(size_file, ec)) {
                try {
                    uint64_t size = lexical_cast<uint64_t>(trim(file::read(size_file)));
                    facts.add(string(fact::block_device) + "_" + device + "_size" , make_value<integer_value>(static_cast<int64_t>(size * 512)));
                } catch (bad_lexical_cast& ex) {
                    LOG_DEBUG("size of block device %1% is invalid: fact %2%_%1%_size is unavailable.", device, fact::block_device);
                }
            }

            // Read the vendor fact
            if (is_regular_file(vendor_file, ec)) {
                facts.add(string(fact::block_device) + "_" + device + "_vendor" , make_value<string_value>(trim(file::read(vendor_file))));
            }

            // Read the model fact
            if (is_regular_file(model_file, ec)) {
                facts.add(string(fact::block_device) + "_" + device + "_model" , make_value<string_value>(trim(file::read(model_file))));
            }

            // Add the device to the devices fact
            if (devices.tellp() != 0) {
                devices << ',';
            }
            devices << device;
        }

        if (devices.tellp() > 0) {
            facts.add(fact::block_devices, make_value<string_value>(devices.str()));
        }
    }

}}}  // namespace facter::facts::linux
