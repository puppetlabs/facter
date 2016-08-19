#include <internal/facts/resolvers/identity_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>

using namespace std;

namespace facter { namespace facts { namespace resolvers {

    identity_resolver::identity_resolver() :
        resolver(
            "id",
            {
                fact::id,
                fact::gid,
                fact::identity
            })
    {
    }

    void identity_resolver::resolve(collection &facts, set<string> const& blocklist)
    {
        auto data = collect_data(facts);

        auto identity = make_value<map_value>();
        if (!data.user_name.empty()) {
            facts.add(fact::id, make_value<string_value>(data.user_name, true));
            identity->add("user", make_value<string_value>(move(data.user_name)));
        }
        if (data.user_id) {
            identity->add("uid", make_value<integer_value>(*data.user_id));
        }
        if (!data.group_name.empty()) {
            facts.add(fact::gid, make_value<string_value>(data.group_name, true));
            identity->add("group", make_value<string_value>(move(data.group_name)));
        }
        if (data.group_id) {
            identity->add("gid", make_value<integer_value>(*data.group_id));
        }
        if (data.privileged) {
            identity->add("privileged", make_value<boolean_value>(*data.privileged));
        }

        if (!identity->empty()) {
            facts.add(fact::identity, move(identity));
        }
    }

}}}  // facter::facts::resolvers
