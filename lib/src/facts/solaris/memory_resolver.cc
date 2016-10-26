#include <internal/facts/solaris/memory_resolver.hpp>
#include <internal/util/solaris/k_stat.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/algorithm/string.hpp>
#include <sys/sysinfo.h>
#include <sys/sysconfig.h>
#include <sys/stat.h>
#include <sys/swap.h>

using namespace std;
using namespace facter::util::solaris;
using namespace leatherman::execution;
using namespace leatherman::util;

namespace facter { namespace facts { namespace solaris {

    memory_resolver::data memory_resolver::collect_data(collection& facts)
    {
        data result;

        const uint64_t page_size = sysconf(_SC_PAGESIZE);
        const auto max_dev_size = PATH_MAX;

        try {
            k_stat ks;
            auto ke = ks[make_pair("unix", "system_pages")][0];
            result.mem_total = ke.value<ulong_t>("physmem") * page_size;
            result.mem_free = ke.value<ulong_t>("pagesfree") * page_size;
        } catch (kstat_exception &ex) {
            LOG_DEBUG("failed to read memory facts from kstat api: {1}.", ex.what());

            uint64_t physmem, pagesfree;

            static boost::regex physmem_rx("^\\s*physmem\\s+(.+)$");
            static boost::regex pagesfree_rx("^\\s*pagesfree\\s+(\\d+)$");

            each_line("/usr/bin/kstat", {"-m", "unix", "-n", "system_pages"}, [&] (string& line) {
                if (re_search(line, physmem_rx, &physmem)) {
                    result.mem_total = physmem * page_size;
                } else if (re_search(line, pagesfree_rx, &pagesfree)) {
                    result.mem_free = pagesfree * page_size;
                }
                return result.mem_total == 0 || result.mem_free == 0;
            });
        }

        // Swap requires a little more effort. See
        // https://community.oracle.com/thread/1951228?start=0&tstart=0
        // http://www.brendangregg.com/K9Toolkit/swapinfo
        int num = 0;
        if ((num = swapctl(SC_GETNSWP,  0)) == -1) {
            LOG_DEBUG("swapctl failed: {1} ({2}): swap information is unavailable", strerror(errno), errno);
            return result;
        }
        if (num == 0) {
            // no swap devices configured
            return result;
        }

        // swap devices can be added online. So add one extra.
        num++;

        vector<char> buffer(num * sizeof(swapent_t) + sizeof(swaptbl_t));
        vector<vector<char>> str_table(num);

        swaptbl_t* swaps = reinterpret_cast<swaptbl_t*>(buffer.data());
        swaps->swt_n = num;

        for (int i = 0; i < num; i++) {
            str_table[i].resize(max_dev_size);
            swaps->swt_ent[i].ste_path = str_table[i].data();
        }

        if (swapctl(SC_LIST, swaps) == -1) {
            LOG_DEBUG("swapctl with SC_LIST failed: {1} ({2}): swap information is unavailable", strerror(errno), errno);
            return result;
        }

        for (int i = 0; i < num; i++) {
            result.swap_free += swaps->swt_ent[i].ste_free;
            result.swap_total += swaps->swt_ent[i].ste_pages;
        }

        result.swap_free *= page_size;
        result.swap_total *= page_size;

        return result;
    }
}}}  // namespace facter::facts::solaris
