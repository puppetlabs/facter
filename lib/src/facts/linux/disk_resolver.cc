#include <internal/facts/linux/disk_resolver.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/file_util/directory.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace boost::filesystem;
using boost::lexical_cast;
using boost::bad_lexical_cast;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace linux {

    disk_resolver::data disk_resolver::collect_data(collection& facts)
    {
        static string root_directory = "/sys/block";

        // The size of the block devices is in 512 byte blocks
        const int block_size = 512;

        data result;

        boost::system::error_code ec;
        if (!is_directory(root_directory, ec)) {
            LOG_DEBUG("{1}: {2}: disk facts are unavailable.", root_directory, ec.message());
            return result;
        }

        lth_file::each_subdirectory(root_directory, [&](string const& dir) {
            path device_directory(dir);

            disk d;
            d.name = device_directory.filename().string();

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
            // The size is in 512 byte blocks
            if (is_regular_file(size_file_path, ec)) {
                try {
                    string blocks = lth_file::read(size_file_path);
                    boost::trim(blocks);
                    d.size = lexical_cast<uint64_t>(blocks) * block_size;
                } catch (bad_lexical_cast& ex) {
                    LOG_DEBUG("size of disk {1} is invalid: size information is unavailable.", d.name);
                }
            }

            // Read the vendor fact
            if (is_regular_file(vendor_file_path, ec)) {
                d.vendor = lth_file::read(vendor_file_path);
                boost::trim(d.vendor);
            }

            // Read the model fact
            if (is_regular_file(model_file_path, ec)) {
                d.model = lth_file::read(model_file_path);
                boost::trim(d.model);
            }

            result.disks.emplace_back(move(d));
            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::linux
