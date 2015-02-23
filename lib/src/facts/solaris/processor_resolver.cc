#include <facter/facts/solaris/processor_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <facter/util/solaris/k_stat.hpp>
#include <unordered_set>
#include <sys/processor.h>

using namespace std;
using namespace facter::util::solaris;

/*
 * https://blogs.oracle.com/mandalika/entry/solaris_show_me_the_cpu
 * What we want to do is to count the distinct number of chip_id (#nproc),
 * then the distinct number of core_id (#ncores) and the number of instances
 * of hardware threads (given by valid procid).
 *
 * Our info comes from the following structure
 *
 $ kstat -m cpu_info
   module: cpu_info                        instance: 0
   name:   cpu_info0                       class:    misc
           brand                           Intel(r) Core(tm) i7-4850HQ CPU @ 2.30GHz
           cache_id                        0
           chip_id                         0
           clock_MHz                       2300
           clog_id                         0
           core_id                         0
           cpu_type                        i386
           crtime                          6.654772184
           current_clock_Hz                2294715939
           current_cstate                  0
           family                          6
           fpu_type                        i387 compatible
           implementation                  x86 (chipid 0x0 GenuineIntel family 6 model 70 step 1 clock 2300 MHz)
           model                           70
           ncore_per_chip                  1
           ncpu_per_chip                   1
           pg_id                           -1
           pkg_core_id                     0
           snaptime                        22631.883297199
           state                           on-line
           state_begin                     1409334365
           stepping                        1
           supported_frequencies_Hz        2294715939
           supported_max_cstates           1
           vendor_id                       GenuineIntel
 */

namespace facter { namespace facts { namespace solaris {

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        auto result = posix::processor_resolver::collect_data(facts);

        try {
            unordered_set<int> chips;

            k_stat kc;
            auto kv = kc["cpu_info"];
            for (auto const& ke : kv) {
                try {
                    ++result.logical_count;
                    result.models.emplace_back(ke.value<string>("brand"));
                    chips.insert(ke.value<int32_t>("chip_id"));

                    // Get the speed of the first processor
                    if (result.speed == 0) {
                        result.speed = static_cast<int64_t>(ke.value<uint64_t>("current_clock_Hz"));
                    }
                } catch (kstat_exception& ex) {
                    LOG_DEBUG("failed to read processor data: %1%.", ex.what());
                }
            }
            result.physical_count = chips.size();
        } catch (kstat_exception& ex) {
            LOG_DEBUG("failed to read processor data: %1%.", ex.what());
        }
        return result;
    }
}}}  // namespace facter::facts::solaris
