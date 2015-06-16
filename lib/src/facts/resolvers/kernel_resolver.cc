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

    void kernel_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);
        if (!data.name.empty()) {
            facts.add(fact::kernel, make_value<string_value>(move(data.name)));
        }

        if (!data.release.empty()) {
            facts.add(fact::kernel_release, make_value<string_value>(move(data.release)));
        }

        if(!data.full_version.empty()) {
            facts.add(fact::kernel_version, make_value<string_value>(move(data.full_version)));
        }

        if (!data.major_version.empty()) {
            facts.add(fact::kernel_major_version, make_value<string_value>(move(data.major_version)));
        }

        // TODO: place minor_version in a structured fact; no point adding a new flat fact for it
    }

}}}  // namespace facter::facts::resolvers
