#include <facter/facts/resolvers/identity_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    identity_resolver::identity_resolver() :
        resolver(
            "id",
            {
                fact::id,
                fact::gid,
            })
    {
    }

    void identity_resolver::resolve(collection &facts)
    {
        // TODO: this (and the ids) should be in a structured fact called something like "identity"
        auto data = collect_data(facts);
        if (!data.user_name.empty()) {
            facts.add(fact::id, make_value<string_value>(move(data.user_name)));
        }
        if (!data.group_name.empty()) {
            facts.add(fact::gid, make_value<string_value>(move(data.group_name)));
        }
    }

}}}  // facter::facts::resolvers
