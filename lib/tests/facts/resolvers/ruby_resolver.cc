#include <catch.hpp>
#include <internal/facts/resolvers/ruby_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_ruby_resolver : ruby_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_ruby_resolver : ruby_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.platform = "i386-mingw32";
        result.sitedir = "C:/Ruby21/lib/ruby/site_ruby/2.1.0";
        result.version = "2.1.4";
        return result;
    }
};

SCENARIO("using the ruby resolver") {
    collection facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_ruby_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_ruby_resolver>());
        THEN("a structured fact is added") {
            REQUIRE(facts.size() == 4u);
            auto ruby = facts.get<map_value>(fact::ruby);
            REQUIRE(ruby);
            REQUIRE(ruby->size() == 3u);
            auto platform = ruby->get<string_value>("platform");
            REQUIRE(platform);
            REQUIRE(platform->value() == "i386-mingw32");
            auto sitedir = ruby->get<string_value>("sitedir");
            REQUIRE(sitedir);
            REQUIRE(sitedir->value() == "C:/Ruby21/lib/ruby/site_ruby/2.1.0");
            auto version = ruby->get<string_value>("version");
            REQUIRE(version);
            REQUIRE(version->value() == "2.1.4");
        }
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 4u);
            auto platform = facts.get<string_value>(fact::rubyplatform);
            REQUIRE(platform);
            REQUIRE(platform->value() == "i386-mingw32");
            auto sitedir = facts.get<string_value>(fact::rubysitedir);
            REQUIRE(sitedir);
            REQUIRE(sitedir->value() == "C:/Ruby21/lib/ruby/site_ruby/2.1.0");
            auto version = facts.get<string_value>(fact::rubyversion);
            REQUIRE(version);
            REQUIRE(version->value() == "2.1.4");
        }
    }
}
