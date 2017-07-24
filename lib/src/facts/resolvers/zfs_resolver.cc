#include <internal/facts/resolvers/zfs_resolver.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace leatherman::execution;
using namespace leatherman::util;

namespace facter { namespace facts { namespace resolvers {

    zfs_resolver::zfs_resolver() :
        resolver(
            "ZFS",
            {
                fact::zfs_version,
                fact::zfs_versionnumbers
            })
    {
    }

    void zfs_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        if (!data.version.empty()) {
            facts.add(fact::zfs_version, make_value<string_value>(move(data.version)));
        }
        if (!data.versions.empty()) {
            facts.add(fact::zfs_versionnumbers, make_value<string_value>(boost::join(data.versions, ",")));
        }
    }

    zfs_resolver::data zfs_resolver::collect_data(collection& facts)
    {
        data result;

        // Get the ZFS version
        static boost::regex zfs_version("currently running ZFS filesystem version (\\d+)[.]");
        each_line(zfs_command(), {"upgrade"}, [&] (string& line) {
            if (re_search(line, zfs_version, &result.version)) {
                return false;
            }
            return true;
        });

        // Get the ZFS versions
        static boost::regex zfs_supported_version("^\\s*(\\d+)[ ]");
        each_line(zfs_command(), {"upgrade", "-v"}, [&] (string& line) {
            string version;
            if (re_search(line, zfs_supported_version, &version)) {
                result.versions.emplace_back(move(version));
            }
            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::resolvers
