#include <internal/facts/solaris/disk_resolver.hpp>
#include <internal/util/solaris/k_stat.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::util::solaris;

namespace facter { namespace facts { namespace solaris {

    disk_resolver::data disk_resolver::collect_data(collection& facts)
    {
        try {
            data result;
            k_stat ks;
            auto ke = ks["sderr"];
            for (auto& kv : ke) {
                disk d;
                string name = kv.name();
                d.name = name.substr(0, name.find(','));
                d.product = kv.value<string>("Product");
                boost::trim(d.product);
                d.vendor = kv.value<string>("Vendor");
                boost::trim(d.vendor);
                d.size = static_cast<int64_t>(kv.value<uint64_t>("Size"));
                result.disks.emplace_back(move(d));
            }
            return result;
        } catch (kstat_exception& ex) {
            LOG_DEBUG("disk information is unavailable: {1}.", ex.what());
            return {};
        }
    }

}}}  // namespace facter::facts::solaris
