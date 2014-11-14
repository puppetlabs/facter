#include <gmock/gmock.h>
#include <facter/facts/resolvers/ruby_resolver.hpp>
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

TEST(facter_facts_resolvers_ruby_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_ruby_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_ruby_resolver, facts)
{
    collection facts;
    facts.add(make_shared<test_ruby_resolver>());
    ASSERT_EQ(4u, facts.size());

    auto platform = facts.get<string_value>(fact::rubyplatform);
    ASSERT_NE(nullptr, platform);
    ASSERT_EQ("i386-mingw32", platform->value());

    auto sitedir = facts.get<string_value>(fact::rubysitedir);
    ASSERT_NE(nullptr, sitedir);
    ASSERT_EQ("C:/Ruby21/lib/ruby/site_ruby/2.1.0", sitedir->value());

    auto version = facts.get<string_value>(fact::rubyversion);
    ASSERT_NE(nullptr, version);
    ASSERT_EQ("2.1.4", version->value());

    auto ruby = facts.get<map_value>(fact::ruby);
    ASSERT_NE(nullptr, ruby);
    ASSERT_EQ(3u, ruby->size());

    platform = ruby->get<string_value>("platform");
    ASSERT_NE(nullptr, platform);
    ASSERT_EQ("i386-mingw32", platform->value());

    sitedir = ruby->get<string_value>("sitedir");
    ASSERT_NE(nullptr, sitedir);
    ASSERT_EQ("C:/Ruby21/lib/ruby/site_ruby/2.1.0", sitedir->value());

    version = ruby->get<string_value>("version");
    ASSERT_NE(nullptr, version);
    ASSERT_EQ("2.1.4", version->value());
}
