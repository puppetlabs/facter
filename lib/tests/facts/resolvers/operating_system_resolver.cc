#include <gmock/gmock.h>
#include <facter/facts/resolvers/operating_system_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_os_resolver : operating_system_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_os_resolver : operating_system_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.name = "Archlinux";
        result.release = "1.2.3";
        result.specification_version = "1.4";
        result.distro.id = "Arch";
        result.distro.release = "1.2.3";
        result.distro.codename = "awesomesauce";
        result.distro.description = "best distro ever";
        result.osx.product = "Mac OS X";
        result.osx.build = "14A388b";
        result.osx.version = "10.10";
        return result;
    }

    virtual tuple<string, string> parse_release(string const& name, string const& release) const override
    {
        return make_tuple("1.2", "3");
    }
};

TEST(facter_facts_resolvers_os_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_os_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_os_resolver, facts)
{
    collection facts;
    facts.add(make_shared<test_os_resolver>());
    ASSERT_EQ(17u, facts.size());

    auto name = facts.get<string_value>(fact::operating_system);
    ASSERT_NE(nullptr, name);
    ASSERT_EQ("Archlinux", name->value());

    auto release = facts.get<string_value>(fact::operating_system_release);
    ASSERT_NE(nullptr, release);
    ASSERT_EQ("1.2.3", release->value());

    auto major = facts.get<string_value>(fact::operating_system_major_release);
    ASSERT_NE(nullptr, major);
    ASSERT_EQ("1.2", major->value());

    auto family = facts.get<string_value>(fact::os_family);
    ASSERT_NE(nullptr, family);
    ASSERT_EQ("Archlinux", family->value());

    auto codename = facts.get<string_value>(fact::lsb_dist_codename);
    ASSERT_NE(nullptr, codename);
    ASSERT_EQ("awesomesauce", codename->value());

    auto description = facts.get<string_value>(fact::lsb_dist_description);
    ASSERT_NE(nullptr, description);
    ASSERT_EQ("best distro ever", description->value());

    auto id = facts.get<string_value>(fact::lsb_dist_id);
    ASSERT_NE(nullptr, id);
    ASSERT_EQ("Arch", id->value());

    release = facts.get<string_value>(fact::lsb_dist_release);
    ASSERT_NE(nullptr, release);
    ASSERT_EQ("1.2.3", release->value());

    major = facts.get<string_value>(fact::lsb_dist_major_release);
    ASSERT_NE(nullptr, major);
    ASSERT_EQ("1.2", major->value());

    auto minor = facts.get<string_value>(fact::lsb_dist_minor_release);
    ASSERT_NE(nullptr, minor);
    ASSERT_EQ("3", minor->value());

    auto lsbrelease = facts.get<string_value>(fact::lsb_release);
    ASSERT_NE(nullptr, lsbrelease);
    ASSERT_EQ("1.4", lsbrelease->value());

    auto os = facts.get<map_value>(fact::os);
    ASSERT_NE(nullptr, os);
    ASSERT_EQ(5u, os->size());

    auto distro = os->get<map_value>("distro");
    ASSERT_NE(nullptr, distro);
    ASSERT_EQ(5u, distro->size());

    codename = distro->get<string_value>("codename");
    ASSERT_NE(nullptr, codename);
    ASSERT_EQ("awesomesauce", codename->value());

    description = distro->get<string_value>("description");
    ASSERT_NE(nullptr, description);
    ASSERT_EQ("best distro ever", description->value());

    id = distro->get<string_value>("id");
    ASSERT_NE(nullptr, description);
    ASSERT_EQ("Arch", id->value());

    lsbrelease = distro->get<string_value>("specification");
    ASSERT_NE(nullptr, lsbrelease);
    ASSERT_EQ("1.4", lsbrelease->value());

    auto release_attribute = distro->get<map_value>("release");
    ASSERT_NE(nullptr, release_attribute);
    ASSERT_EQ(3u, release_attribute->size());

    release = release_attribute->get<string_value>("full");
    ASSERT_NE(nullptr, release);
    ASSERT_EQ("1.2.3", release->value());

    major = release_attribute->get<string_value>("major");
    ASSERT_NE(nullptr, major);
    ASSERT_EQ("1.2", major->value());

    minor = release_attribute->get<string_value>("minor");
    ASSERT_NE(nullptr, minor);
    ASSERT_EQ("3", minor->value());

    family = os->get<string_value>("family");
    ASSERT_NE(nullptr, family);
    ASSERT_EQ("Archlinux", family->value());

    name = os->get<string_value>("name");
    ASSERT_NE(nullptr, name);
    ASSERT_EQ("Archlinux", name->value());

    release_attribute = os->get<map_value>("release");
    ASSERT_NE(nullptr, release_attribute);
    ASSERT_EQ(3u, release_attribute->size());

    release = release_attribute->get<string_value>("full");
    ASSERT_NE(nullptr, release);
    ASSERT_EQ("1.2.3", release->value());

    major = release_attribute->get<string_value>("major");
    ASSERT_NE(nullptr, major);
    ASSERT_EQ("1.2", major->value());

    minor = release_attribute->get<string_value>("minor");
    ASSERT_NE(nullptr, minor);
    ASSERT_EQ("3", minor->value());

    auto macosx = os->get<map_value>("macosx");
    ASSERT_NE(nullptr, macosx);
    ASSERT_EQ(3u, macosx->size());

    auto product = macosx->get<string_value>("product");
    ASSERT_NE(nullptr, product);
    ASSERT_EQ("Mac OS X", product->value());

    auto build = macosx->get<string_value>("build");
    ASSERT_NE(nullptr, build);
    ASSERT_EQ("14A388b", build->value());

    release_attribute = macosx->get<map_value>("version");
    ASSERT_NE(nullptr, release_attribute);
    ASSERT_EQ(3u, release_attribute->size());

    release = release_attribute->get<string_value>("full");
    ASSERT_NE(nullptr, release);
    ASSERT_EQ("10.10", release->value());

    major = release_attribute->get<string_value>("major");
    ASSERT_NE(nullptr, major);
    ASSERT_EQ("10.10", major->value());

    minor = release_attribute->get<string_value>("minor");
    ASSERT_NE(nullptr, minor);
    ASSERT_EQ("0", minor->value());

    build = facts.get<string_value>(fact::macosx_buildversion);
    ASSERT_NE(nullptr, build);
    ASSERT_EQ("14A388b", build->value());

    product = facts.get<string_value>(fact::macosx_productname);
    ASSERT_NE(nullptr, product);
    ASSERT_EQ("Mac OS X", product->value());

    release = facts.get<string_value>(fact::macosx_productversion);
    ASSERT_NE(nullptr, release);
    ASSERT_EQ("10.10", release->value());

    major = facts.get<string_value>(fact::macosx_productversion_major);
    ASSERT_NE(nullptr, major);
    ASSERT_EQ("10.10", major->value());

    minor = facts.get<string_value>(fact::macosx_productversion_minor);
    ASSERT_NE(nullptr, minor);
    ASSERT_EQ("0", minor->value());
}
