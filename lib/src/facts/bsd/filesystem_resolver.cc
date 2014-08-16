#include <facter/facts/bsd/filesystem_resolver.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/string.hpp>
#include <boost/algorithm/string.hpp>
#include <sys/param.h>
#include <sys/ucred.h>
#include <sys/mount.h>
#include <tuple>

using namespace std;
using namespace facter::facts;
using namespace facter::util;

LOG_DECLARE_NAMESPACE("facts.bsd.filesystem");

namespace facter { namespace facts { namespace bsd {

    void filesystem_resolver::resolve_mountpoints(collection& facts)
    {
        // First get the count of file systems
        int count = getfsstat(nullptr, 0, MNT_NOWAIT);
        if (count == -1) {
            LOG_ERROR("getfsstat failed: %1% (%2%): file system facts are unavailable.", strerror(errno), errno);
            return;
        }

        // Get the actual data
        vector<struct statfs> filesystems(count);
        count = getfsstat(filesystems.data(), filesystems.size() * sizeof(struct statfs), MNT_NOWAIT);
        if (count == -1) {
            LOG_ERROR("getfsstat failed: %1% (%2%): file system facts are unavailable.", strerror(errno), errno);
            return;
        }

        // Populate an entry for each mounted file system
        auto mountpoints = make_value<map_value>();
        for (auto& fs : filesystems) {
            uint64_t size = fs.f_bsize * fs.f_blocks;
            uint64_t available = fs.f_bsize * fs.f_bfree;
            uint64_t used = size - available;

            auto value = make_value<map_value>();
            value->add("size_bytes", make_value<integer_value>(size));
            value->add("size", make_value<string_value>(si_string(size)));
            value->add("available_bytes", make_value<integer_value>(available));
            value->add("available", make_value<string_value>(si_string(available)));
            value->add("used_bytes", make_value<integer_value>(used));
            value->add("used", make_value<string_value>(si_string(used)));
            value->add("capacity", make_value<string_value>(percentage(used, size)));
            value->add("options", make_options_value(fs));
            value->add("filesystem", make_value<string_value>(fs.f_fstypename));
            value->add("device", make_value<string_value>(fs.f_mntfromname));
            mountpoints->add(fs.f_mntonname, move(value));
        }

        if (mountpoints->size() > 0) {
            facts.add(fact::mountpoints, move(mountpoints));
        }
    }

    void filesystem_resolver::resolve_filesystems(collection& facts)
    {
        auto mountpoints = facts.get<map_value>(fact::mountpoints, false);
        if (!mountpoints) {
            return;
        }

        // Build a list of mounted filesystems
        // This differs from Linux because it only lists actively mounted filesystems
        // The Linux fact displays what filesystems are supported by the kernel
        set<string> filesystems;
        mountpoints->each([&](string const&, value const* val) {
            auto mountpoint = dynamic_cast<map_value const*>(val);
            if (!mountpoint) {
                return true;
            }

            auto filesystem = mountpoint->get<string_value>("filesystem");
            if (!filesystem) {
                return true;
            }

            filesystems.insert(filesystem->value());
            return true;
        });

        if (filesystems.size() == 0) {
            return;
        }

        facts.add(fact::filesystems, make_value<string_value>(boost::join(filesystems, ",")));
    }

    void filesystem_resolver::resolve_partitions(collection& facts)
    {
        // Not implemented for BSD
    }

    unique_ptr<array_value> filesystem_resolver::make_options_value(struct statfs const& fs)
    {
        static vector<tuple<unsigned int, string>> const flags = {
            { MNT_RDONLY,       "readonly" },
            { MNT_SYNCHRONOUS,  "noasync" },
            { MNT_NOEXEC,       "noexec" },
            { MNT_NOSUID,       "nosuid" },
            { MNT_NODEV,        "nodev" },
            { MNT_UNION,        "union" },
            { MNT_ASYNC,        "async" },
            { MNT_EXPORTED,     "exported" },
            { MNT_LOCAL,        "local" },
            { MNT_QUOTA,        "quota" },
            { MNT_ROOTFS,       "root" },
            { MNT_DONTBROWSE,   "nobrowse" },
            { MNT_AUTOMOUNTED,  "automounted" },
            { MNT_JOURNALED,    "journaled" },
            { MNT_DEFWRITE,     "deferwrites" },
        };

        auto options = make_value<array_value>();
        for (auto const& flag : flags) {
            if (fs.f_flags & get<0>(flag)) {
                options->add(make_value<string_value>(get<1>(flag)));
            }
        }
        return options;
    }

}}}  // namespace facter::facts::bsd
