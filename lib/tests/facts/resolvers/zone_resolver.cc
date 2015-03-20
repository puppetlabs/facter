#include <catch.hpp>
#include <internal/facts/resolvers/zone_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_zone_resolver : zone_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        return result;
    }
};

struct test_zone_resolver : zone_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.current_zone_name = "current";

        zone z;
        z.uuid = "uuid";
        z.status = "status";
        z.path = "path";
        z.name = "name";
        z.brand = "brand";
        z.id = "id";
        z.ip_type = "ip type";
        result.zones.emplace_back(move(z));
        return result;
    }
};

SCENARIO("using the Solaris zone resolver") {
    collection facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_zone_resolver>());
        THEN("only the zone count should be added") {
            REQUIRE(facts.size() == 1);
            auto value = facts.get<integer_value>(fact::zones);
            REQUIRE(value);
            REQUIRE(value->value() == 0);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_zone_resolver>());
        THEN("a structured fact is added") {
            REQUIRE(facts.size() == 10);
            auto mval = facts.get<map_value>(fact::solaris_zones);
            REQUIRE(mval);
            REQUIRE(mval->size() == 2);
            auto sval = mval->get<string_value>("current");
            REQUIRE(sval);
            REQUIRE(sval->value() == "current");
            mval = mval->get<map_value>("zones");
            REQUIRE(mval);
            REQUIRE(mval->size() == 1);
            mval = mval->get<map_value>("name");
            REQUIRE(mval);
            REQUIRE(mval->size() == 6);
            sval = mval->get<string_value>("uuid");
            REQUIRE(sval);
            REQUIRE(sval->value() == "uuid");
            sval = mval->get<string_value>("status");
            REQUIRE(sval);
            REQUIRE(sval->value() == "status");
            sval = mval->get<string_value>("path");
            REQUIRE(sval);
            REQUIRE(sval->value() == "path");
            sval = mval->get<string_value>("brand");
            REQUIRE(sval);
            REQUIRE(sval->value() == "brand");
            sval = mval->get<string_value>("id");
            REQUIRE(sval);
            REQUIRE(sval->value() == "id");
            sval = mval->get<string_value>("ip_type");
            REQUIRE(sval);
            REQUIRE(sval->value() == "ip type");
        }
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 10);
            auto ival = facts.get<integer_value>(fact::zones);
            REQUIRE(ival);
            REQUIRE(ival->value() == 1);
            auto sval = facts.get<string_value>(fact::zonename);
            REQUIRE(sval);
            REQUIRE(sval->value() == "current");
            sval = facts.get<string_value>(string("zone_name_") + fact::zone_iptype);
            REQUIRE(sval);
            REQUIRE(sval->value() == "ip type");
            sval = facts.get<string_value>(string("zone_name_") + fact::zone_brand);
            REQUIRE(sval);
            REQUIRE(sval->value() == "brand");
            sval = facts.get<string_value>(string("zone_name_") + fact::zone_uuid);
            REQUIRE(sval);
            REQUIRE(sval->value() == "uuid");
            sval = facts.get<string_value>(string("zone_name_") + fact::zone_id);
            REQUIRE(sval);
            REQUIRE(sval->value() == "id");
            sval = facts.get<string_value>(string("zone_name_") + fact::zone_name);
            REQUIRE(sval);
            REQUIRE(sval->value() == "name");
            sval = facts.get<string_value>(string("zone_name_") + fact::zone_path);
            REQUIRE(sval);
            REQUIRE(sval->value() == "path");
            sval = facts.get<string_value>(string("zone_name_") + fact::zone_status);
            REQUIRE(sval);
            REQUIRE(sval->value() == "status");
        }
    }
}
