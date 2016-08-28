#include <internal/facts/resolvers/kernel_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/fact.hpp>

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    kernel_resolver::kernel_resolver() :
        resolver(
            "kernel",
            {
                fact::kernel,
                fact::kernel_version,
                fact::kernel_release,
                fact::kernel_major_version
            })
    {
    }

    void kernel_resolver::resolve(collection& facts, set<string> const& blocklist)
    {
        auto data = collect_data(facts);
        if (!data.name.empty()) {
            facts.add(fact::kernel, make_value<string_value>(move(data.name)));
        }

        if (!data.release.empty()) {
            facts.add(fact::kernel_release, make_value<string_value>(move(data.release)));
        }

        if (!data.version.empty()) {
            string major, minor;
            tie(major, minor) = parse_version(data.version);

            if (!major.empty()) {
                facts.add(fact::kernel_major_version, make_value<string_value>(move(major)));
            }
            if (!minor.empty()) {
                // TODO: for use in a structured fact; no point adding a new flat fact for it
            }

            facts.add(fact::kernel_version, make_value<string_value>(move(data.version)));
        }
    }

    tuple<string, string> kernel_resolver::parse_version(string const& version) const
    {
        auto pos = version.find('.');
        if (pos != string::npos) {
            auto second = version.find('.', pos + 1);
            if (second != string::npos) {
                pos = second;
            }
            return make_tuple(version.substr(0, pos), version.substr(pos + 1));
        }
        return make_tuple(move(version), string());
    }

}}}  // namespace facter::facts::resolvers
