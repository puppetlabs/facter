#include <internal/facts/resolvers/fips_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>

using namespace std;
using namespace facter::facts;

namespace facter { namespace facts { namespace resolvers {

    fips_resolver::fips_resolver() :
        resolver("fips", {fact::fips_enabled})
    {
    }

    void fips_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);
        facts.add(fact::fips_enabled, make_value<boolean_value>(data.is_fips_mode_enabled));
    }

}}}  // namespace facter::facts::resolvers
