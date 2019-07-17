#include <catch.hpp>
#include <internal/facts/resolvers/ldom_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct empty_ldom_resolver : ldom_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        return result;
    }
};

struct test_ldom_resolver : ldom_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        ldom_info single_value;
        single_value.key = "domainname";
        single_value.values.insert({ "domainname", "somedomain"});

        ldom_info multi_value;
        multi_value.key = "domainrole";
        multi_value.values.insert({ "impl", "true"});
        multi_value.values.insert({ "io", "false"});

        data result;
        result.ldom.emplace_back(single_value);
        result.ldom.emplace_back(multi_value);

        return result;
    }
};

SCENARIO("Using the Solaris LDom resolver") {
    collection_fixture facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_ldom_resolver>());
        THEN("no LDom facts should be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_ldom_resolver>());
        THEN("a structured fact is added") {
            REQUIRE(facts.size() == 4u);
            auto ldom = facts.get<map_value>(fact::ldom);
            REQUIRE(ldom);
            REQUIRE(ldom->size() == 2u);

            auto sval = ldom->get<string_value>("domainname");
            REQUIRE(sval);
            REQUIRE(sval->value() == "somedomain");

            auto mval = ldom->get<map_value>("domainrole");
            REQUIRE(mval);
            REQUIRE(mval->size() == 2u);
        }
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 4u);
            auto sval_2 = facts.get<string_value>("ldom_domainname");
            REQUIRE(sval_2);
            REQUIRE(sval_2->value() == "somedomain");

            auto sval_3 = facts.get<string_value>("ldom_domainrole_impl");
            REQUIRE(sval_3);
            REQUIRE(sval_3->value() == "true");

            auto sval_4 = facts.get<string_value>("ldom_domainrole_io");
            REQUIRE(sval_4);
            REQUIRE(sval_4->value() == "false");
        }
    }
}
