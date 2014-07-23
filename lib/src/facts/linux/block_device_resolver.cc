#include <facter/facts/linux/block_device_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/file.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/string.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace facter::util;
using namespace boost;
using namespace boost::filesystem;

LOG_DECLARE_NAMESPACE("facts.linux.blockdevices");

namespace facter { namespace facts { namespace linux {

    block_device_resolver::block_device_resolver() :
        resolver(
            "block device",
            {
                fact::block_devices,
            },
            {
                string("^") + fact::block_device + "_",
            })
    {
    }

    void block_device_resolver::resolve_facts(collection& facts)
    {
        static string root_directory = "/sys/block";

        boost::system::error_code ec;
        if (!is_directory(root_directory, ec)) {
            LOG_DEBUG("%1%: %2%: block device facts are unavailable.", root_directory, ec.message());
            return;
        }

        ostringstream devices;
        directory::each_subdirectory(root_directory, [&](string const& dir) {
            path device_directory(dir);
            string device = device_directory.filename().string();

            // Check for the device subdirectory's existence
            path device_subdirectory = device_directory / "device";
            boost::system::error_code ec;
            if (!is_directory(device_subdirectory, ec)) {
                return true;
            }

            string size_file_path = (device_directory / "size").string();
            string vendor_file_path = (device_subdirectory / "vendor").string();
            string model_file_path = (device_subdirectory / "model").string();

            // Read the size of the block device
            // The size is in 512 byte sectors
            if (is_regular_file(size_file_path, ec)) {
                try {
                    uint64_t size = lexical_cast<uint64_t>(trim(file::read(size_file_path)));
                    facts.add(string(fact::block_device) + "_" + device + "_size" , make_value<integer_value>(static_cast<int64_t>(size) * 512));
                } catch (bad_lexical_cast& ex) {
                    LOG_DEBUG("size of block device %1% is invalid: fact %2%_%1%_size is unavailable.", device, fact::block_device);
                }
            }

            // Read the vendor fact
            if (is_regular_file(vendor_file_path, ec)) {
                facts.add(string(fact::block_device) + "_" + device + "_vendor" , make_value<string_value>(trim(file::read(vendor_file_path))));
            }

            // Read the model fact
            if (is_regular_file(model_file_path, ec)) {
                facts.add(string(fact::block_device) + "_" + device + "_model" , make_value<string_value>(trim(file::read(model_file_path))));
            }

            // Add the device to the devices fact
            if (devices.tellp() != 0) {
                devices << ',';
            }
            devices << device;
            return true;
        });

        if (devices.tellp() > 0) {
            facts.add(fact::block_devices, make_value<string_value>(devices.str()));
        }
    }

}}}  // namespace facter::facts::linux
