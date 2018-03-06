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

        // Set a safe default
        result.is_fips_mode_enabled = false;

        lth_file::each_line("/proc/sys/crypto/fips_enabled", [&](string& line) {
            boost::trim(line);
            result.is_fips_mode_enabled = line != "0";

            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::linux
