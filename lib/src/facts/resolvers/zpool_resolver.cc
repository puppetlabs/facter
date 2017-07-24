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
                fact::zpool_featureflags,
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
        if (!data.feature_flags.empty()) {
            facts.add(fact::zpool_featureflags, make_value<string_value>(boost::join(data.feature_flags, ",")));
        }
        if (!data.versions.empty()) {
            facts.add(fact::zpool_versionnumbers, make_value<string_value>(boost::join(data.versions, ",")));
        }
    }

    zpool_resolver::data zpool_resolver::collect_data(collection& facts)
    {
        data result;

        enum { UNKNOWN, FEATURES, VERSIONS } state = UNKNOWN;

        // Get the zpool version and features
        static boost::regex zpool_version("^This system is currently running ZFS pool version (\\d+)\\.$");
        static boost::regex zpool_feature_flags("^This system supports ZFS pool feature flags\\.$");

        static boost::regex zpool_supported_feature_header("^The following features are supported:$");
        static boost::regex zpool_supported_versions_header("^The following versions are supported:$");
        static boost::regex zpool_supported_legacy_versions_header("^The following legacy versions are also supported:$");

        static boost::regex zpool_supported_feature("^([[:alnum:]_]+)(\\s+\\(read-only compatible\\))?$");
        static boost::regex zpool_supported_version("^\\s*(\\d+)[ ]");

        string feature;
        each_line(zpool_command(), {"upgrade", "-v"}, [&] (string& line) {
            switch (state) {
            case UNKNOWN:
                if (re_search(line, zpool_version, &result.version)) {
                } else if (re_search(line, zpool_feature_flags)) {
                    result.version = "1000";
                } else if (re_search(line, zpool_supported_feature_header)) {
                    state = FEATURES;
                } else if (re_search(line, zpool_supported_versions_header)) {
                    state = VERSIONS;
                }
                break;

            case FEATURES:
                if (re_search(line, zpool_supported_feature, &feature)) {
                    result.feature_flags.emplace_back(move(feature));
                } else if (re_search(line, zpool_supported_legacy_versions_header)) {
                    state = VERSIONS;
                }
                break;

            case VERSIONS:
                string feature;
                if (re_search(line, zpool_supported_version, &feature)) {
                    result.versions.emplace_back(move(feature));
                }
                break;
            }
            return true;
        });
        return result;
    }

}}}  // namespace facter::facts::resolvers
