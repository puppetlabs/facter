#include <internal/facts/linux/memory_resolver.hpp>
#include <leatherman/file_util/file.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>

using namespace std;

using boost::lexical_cast;
using boost::bad_lexical_cast;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace linux {

    memory_resolver::data memory_resolver::collect_data(collection& facts)
    {
        data result;
        lth_file::each_line("/proc/meminfo", [&](string& line) {
            uint64_t* variable = nullptr;
            if (boost::starts_with(line, "MemTotal:")) {
                variable = &result.mem_total;
            } else if (boost::starts_with(line, "MemFree:") ||
                       boost::starts_with(line, "Buffers:") ||
                       boost::starts_with(line, "Cached:")) {
                variable = &result.mem_free;
            } else if (boost::starts_with(line, "SwapTotal:")) {
                variable = &result.swap_total;
            } else if (boost::starts_with(line, "SwapFree:")) {
                variable = &result.swap_free;
            }
            if (!variable) {
                return true;
            }

            vector<boost::iterator_range<string::iterator>> parts;
            boost::split(parts, line, boost::is_space(), boost::token_compress_on);
            if (parts.size() < 2) {
                return true;
            }

            try {
                *variable += lexical_cast<uint64_t>(parts[1]) * 1024;
            } catch (bad_lexical_cast&) {
            }
            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::linux
