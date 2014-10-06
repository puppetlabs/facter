#include <gmock/gmock.h>
#include <facter/facts/resolvers/virtualization_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/vm.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_virtualization_resolver : virtualization_resolver
{
 protected:
    virtual string get_hypervisor(collection& facts) override
    {
        return {};
    }
};

struct unknown_hypervisor_resolver : virtualization_resolver
{
 protected:
    virtual string get_hypervisor(collection& facts) override
    {
        return "foobar";
    }
};

struct unknown_non_virtual_hypervisor_resolver : virtualization_resolver
{
 protected:
    virtual string get_hypervisor(collection& facts) override
    {
        return "foobar";
    }

    virtual bool is_virtual(string const& hypervisor)
    {
        return hypervisor != "foobar";
    }
};

struct known_hypervisor_resolver : virtualization_resolver
{
 protected:
    virtual string get_hypervisor(collection& facts) override
    {
        return vm::docker;
    }
};

TEST(facter_facts_resolvers_virtualization_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_virtualization_resolver>());
    ASSERT_EQ(2u, facts.size());

    auto is_virt = facts.get<boolean_value>(fact::is_virtual);
    ASSERT_NE(nullptr, is_virt);
    ASSERT_FALSE(is_virt->value());

    auto hypervisor = facts.get<string_value>(fact::virtualization);
    ASSERT_NE(nullptr, hypervisor);
    ASSERT_EQ("physical", hypervisor->value());
}

TEST(facter_facts_resolvers_virtualization_resolver, unknown_hypervisor)
{
    collection facts;
    facts.add(make_shared<unknown_hypervisor_resolver>());
    ASSERT_EQ(2u, facts.size());

    auto is_virt = facts.get<boolean_value>(fact::is_virtual);
    ASSERT_NE(nullptr, is_virt);
    ASSERT_TRUE(is_virt->value());

    auto hypervisor = facts.get<string_value>(fact::virtualization);
    ASSERT_NE(nullptr, hypervisor);
    ASSERT_EQ("foobar", hypervisor->value());
}

TEST(facter_facts_resolvers_virtualization_resolver, unknown_non_virtual_hypervisor)
{
    collection facts;
    facts.add(make_shared<unknown_non_virtual_hypervisor_resolver>());
    ASSERT_EQ(2u, facts.size());

    auto is_virt = facts.get<boolean_value>(fact::is_virtual);
    ASSERT_NE(nullptr, is_virt);
    ASSERT_FALSE(is_virt->value());

    auto hypervisor = facts.get<string_value>(fact::virtualization);
    ASSERT_NE(nullptr, hypervisor);
    ASSERT_EQ("foobar", hypervisor->value());
}

TEST(facter_facts_resolvers_virtualization_resolver, known_hypervisor)
{
    collection facts;
    facts.add(make_shared<known_hypervisor_resolver>());
    ASSERT_EQ(2u, facts.size());

    auto is_virt = facts.get<boolean_value>(fact::is_virtual);
    ASSERT_NE(nullptr, is_virt);
    ASSERT_TRUE(is_virt->value());

    auto hypervisor = facts.get<string_value>(fact::virtualization);
    ASSERT_NE(nullptr, hypervisor);
    ASSERT_EQ(string(vm::docker), hypervisor->value());
}
