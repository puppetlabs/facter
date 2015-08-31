#include <internal/facts/resolvers/ldom_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <iostream>

using namespace std;
using namespace facter::facts;

namespace facter { namespace facts { namespace resolvers {

    ldom_resolver::ldom_resolver() :
        resolver(
            "ldom",
            {
                fact::ldom,
            },
            {
                string("^ldom_"),
            })

    {
    }

    void ldom_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        if (!data.ldom.empty()) {
            auto ldom = make_value<map_value>();

            for (auto& sub_key : data.ldom) {
                if (sub_key.values.size() == 0) {
                    continue;

                } else if (sub_key.values.size() == 1) {
                    string key = sub_key.values.begin()->first;
                    string value = sub_key.values.begin()->second;

                    ldom->add(key, make_value<string_value>(value));
                    facts.add("ldom_" + key, make_value<string_value>(move(value), true));

                } else {
                    // If we have multiple sub key values, insert a map into the structured fact to contain them.
                    auto sub_value = make_value<map_value>();

                    for (auto& kv : sub_key.values) {
                        sub_value->add(kv.first, make_value<string_value>(kv.second));
                        facts.add("ldom_" + sub_key.key + "_" + move(kv.first), make_value<string_value>(move(kv.second), true));
                    }

                    ldom->add(sub_key.key, move(sub_value));
                }
            }

            facts.add(fact::ldom, move(ldom));
        }
    }

}}}  // namespace facter::facts
