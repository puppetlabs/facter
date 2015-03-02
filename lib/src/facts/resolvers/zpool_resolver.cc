#include <facter/facts/resolvers/zpool_resolver.hpp>
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

    zpool_resolver::zpool_resolver() :
        resolver(
            "ZFS storage pool",
            {
                fact::zpool_version,
                fact::zpool_featurenumbers,
            })
    {
    }

    void zpool_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        if (!data.version.empty()) {
            facts.add(fact::zpool_version, make_value<string_value>(move(data.version)));
        }
        if (!data.features.empty()) {
            facts.add(fact::zpool_featurenumbers, make_value<string_value>(boost::join(data.features, ",")));
        }
    }

    zpool_resolver::data zpool_resolver::collect_data(collection& facts)
    {
        data result;

        // Get the zpool version and features
        re_adapter zpool_version("ZFS pool version (\\d+)[.]");
        re_adapter zpool_feature("\\s*(\\d+)[ ]");
        execution::each_line(zpool_command(), {"upgrade", "-v"}, [&] (string& line) {
            if (re_search(line, zpool_version, &result.version)) {
                return true;
            }
            string feature;
            if (re_search(line, zpool_feature, &feature)) {
                result.features.emplace_back(move(feature));
            }
            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::resolvers
