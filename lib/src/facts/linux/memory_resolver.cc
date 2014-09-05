#include <facter/facts/linux/memory_resolver.hpp>
#include <facter/util/file.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>

using namespace std;
using namespace facter::util;

using boost::lexical_cast;
using boost::bad_lexical_cast;

namespace facter { namespace facts { namespace linux {

    bool memory_resolver::get_memory_statistics(
            collection& facts,
            uint64_t& mem_free,
            uint64_t& mem_total,
            uint64_t& swap_free,
            uint64_t& swap_total)
    {
        return file::each_line("/proc/meminfo", [&](string& line) {
            uint64_t* variable = nullptr;
            if (boost::starts_with(line, "MemTotal:")) {
                variable = &mem_total;
            } else if (boost::starts_with(line, "MemFree:") ||
                       boost::starts_with(line, "Buffers:") ||
                       boost::starts_with(line, "Cached:")) {
                variable = &mem_free;
            } else if (boost::starts_with(line, "SwapTotal:")) {
                variable = &swap_total;
            } else if (boost::starts_with(line, "SwapFree:")) {
                variable = &swap_free;
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
    }

}}}  // namespace facter::facts::linux
