#include <internal/facts/freebsd/filesystem_resolver.hpp>
#include <internal/util/freebsd/geom.hpp>
#include <leatherman/logging/logging.hpp>

#include <libgeom.h>

using namespace std;

namespace facter { namespace facts { namespace freebsd {

    filesystem_resolver::data filesystem_resolver::collect_data(collection& facts)
    {
        data result = bsd::filesystem_resolver::collect_data(facts);

        try {
            facter::util::freebsd::geom_class disks("PART");

            for (auto& geom : disks.geoms) {
                for (auto& provider : geom.providers) {
                    partition p;
                    p.name = provider.name();
                    p.size = provider.mediasize();
                    if (geom.config("scheme") == "GPT") {
                        p.partition_label = provider.config("label");
                        p.partition_uuid = provider.config("rawuuid");
                    }
                    result.partitions.push_back(move(p));
                }
            }
        } catch (util::freebsd::geom_exception const& e) {
            LOG_ERROR(e.what());
        }

        return result;
    }

}}}  // namespace facter::facts::freebsd
