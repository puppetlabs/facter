#include <internal/facts/resolvers/zpool_resolver.hpp>
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

    zpool_resolver::zpool_resolver() :
        resolver(
            "ZFS storage pool",
            {
                fact::zpool_version,
                fact::zpool_versionnumbers,
            })
    {
    }

    void zpool_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        if (!data.version.empty()) {
            facts.add(fact::zpool_version, make_value<string_value>(move(data.version)));
        }
        if (!data.versions.empty()) {
            facts.add(fact::zpool_versionnumbers, make_value<string_value>(boost::join(data.versions, ",")));
        }
    }

    zpool_resolver::data zpool_resolver::collect_data(collection& facts)
    {
        data result;

        // Get the zpool version
        static boost::regex zpool_version("ZFS pool version (\\d+)[.]");
        static boost::regex zpool_supported_version("^\\s*(\\d+)[ ]");
        each_line(zpool_command(), {"upgrade", "-v"}, [&] (string& line) {
            if (re_search(line, zpool_version, &result.version)) {
                return true;
            }
            string version;
            if (re_search(line, zpool_supported_version, &version)) {
                result.versions.emplace_back(move(version));
            }
            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::resolvers
