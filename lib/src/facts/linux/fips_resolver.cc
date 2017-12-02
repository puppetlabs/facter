#include <internal/facts/linux/fips_resolver.hpp>
#include <leatherman/file_util/file.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>

using namespace std;

using boost::lexical_cast;
using boost::bad_lexical_cast;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace linux {

    fips_resolver::data fips_resolver::collect_data(collection& facts)
    {
        data result;

        // Below file might not exist in which case we need to ensure to not report
        // anything incorrectly by initializing the result to a safe value
        result.is_fips_mode_enabled = false;

        lth_file::each_line("/proc/sys/crypto/fips_enabled", [&](string& line) {
            boost::trim(line);
            if (line != "0")
                result.is_fips_mode_enabled = true;
            else
                result.is_fips_mode_enabled = false;

            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::linux
