#include <facter/facts/posix/filesystem_resolver.hpp>
#include <facter/facts/fact.hpp>

using namespace std;

namespace facter { namespace facts { namespace posix {

    filesystem_resolver::filesystem_resolver() :
        resolver(
            "file system",
            {
                fact::mountpoints,
                fact::filesystems,
                fact::partitions
            })
    {
    }

    void filesystem_resolver::resolve_facts(collection& facts)
    {
        resolve_mountpoints(facts);
        resolve_filesystems(facts);
        resolve_partitions(facts);
    }

}}}  // namespace facter::facts::posix
