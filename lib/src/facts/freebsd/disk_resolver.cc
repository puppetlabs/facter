#include <internal/facts/freebsd/disk_resolver.hpp>
#include <internal/util/freebsd/geom.hpp>
#include <leatherman/logging/logging.hpp>

#include <libgeom.h>

using namespace std;

namespace facter { namespace facts { namespace freebsd {

    disk_resolver::data disk_resolver::collect_data(collection& facts)
    {
        data result;

        try {
            facter::util::freebsd::geom_class disks("DISK");

            for (auto& geom : disks.geoms) {
                for (auto& provider : geom.providers) {
                    disk d;
                    d.name = provider.name();
                    d.size = provider.mediasize();
                    d.model = provider.config("descr");
                    d.serial_number = provider.config("ident");
                    result.disks.push_back(move(d));
                }
            }
        } catch (util::freebsd::geom_exception const &e) {
            LOG_ERROR(e.what());
        }

        return result;
    }

}}}  // namespace facter::facts::freebsd
