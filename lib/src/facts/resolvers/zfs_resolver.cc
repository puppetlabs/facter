#include <facter/facts/resolvers/zfs_resolver.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/regex.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::execution;
using namespace facter::util;

namespace facter { namespace facts { namespace resolvers {

    zfs_resolver::zfs_resolver() :
        resolver(
            "ZFS",
            {
                fact::zfs_version,
                fact::zfs_featurenumbers
            })
    {
    }

    void zfs_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        if (!data.version.empty()) {
            facts.add(fact::zfs_version, make_value<string_value>(move(data.version)));
        }
        if (!data.features.empty()) {
            facts.add(fact::zfs_featurenumbers, make_value<string_value>(boost::join(data.features, ",")));
        }
    }

    zfs_resolver::data zfs_resolver::collect_data(collection& facts)
    {
        data result;

        // Get the ZFS version
        re_adapter zfs_version("currently running ZFS filesystem version (\\d+)[.]");
        execution::each_line(zfs_command(), {"upgrade"}, [&] (string& line) {
            if (re_search(line, zfs_version, &result.version)) {
                return false;
            }
            return true;
        });

        // Get the ZFS features
        re_adapter zfs_feature("\\s*(\\d+)[ ]");
        execution::each_line(zfs_command(), {"upgrade", "-v"}, [&] (string& line) {
            string feature;
            if (re_search(line, zfs_feature, &feature)) {
                result.features.emplace_back(move(feature));
            }
            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::resolvers
