#include <catch.hpp>
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

SCENARIO("using the virtualization resolver") {
    collection facts;
    WHEN("no hypervisor is returned") {
        facts.add(make_shared<empty_virtualization_resolver>());
        THEN("the system is reported as physical") {
            REQUIRE(facts.size() == 2);
            auto is_virt = facts.get<boolean_value>(fact::is_virtual);
            REQUIRE(is_virt);
            REQUIRE_FALSE(is_virt->value());
            auto hypervisor = facts.get<string_value>(fact::virtualization);
            REQUIRE(hypervisor);
            REQUIRE(hypervisor->value() == "physical");
        }
    }
    WHEN("an unknown virtual hypervisor is returned") {
        facts.add(make_shared<unknown_hypervisor_resolver>());
        THEN("the system is reported as virtual") {
            REQUIRE(facts.size() == 2);
            auto is_virt = facts.get<boolean_value>(fact::is_virtual);
            REQUIRE(is_virt);
            REQUIRE(is_virt->value());
            auto hypervisor = facts.get<string_value>(fact::virtualization);
            REQUIRE(hypervisor);
            REQUIRE(hypervisor->value() == "foobar");
        }
    }
    WHEN("an unknown physical hypervisor is returned") {
        facts.add(make_shared<unknown_non_virtual_hypervisor_resolver>());
        THEN("the system is reported as virtual") {
            REQUIRE(facts.size() == 2);
            auto is_virt = facts.get<boolean_value>(fact::is_virtual);
            REQUIRE(is_virt);
            REQUIRE_FALSE(is_virt->value());
            auto hypervisor = facts.get<string_value>(fact::virtualization);
            REQUIRE(hypervisor);
            REQUIRE(hypervisor->value() == "foobar");
        }
    }
    WHEN("an known hypervisor is returned") {
        facts.add(make_shared<known_hypervisor_resolver>());
        THEN("the system is reported as virtual") {
            REQUIRE(facts.size() == 2);
            auto is_virt = facts.get<boolean_value>(fact::is_virtual);
            REQUIRE(is_virt);
            REQUIRE(is_virt->value());
            auto hypervisor = facts.get<string_value>(fact::virtualization);
            REQUIRE(hypervisor);
            REQUIRE(hypervisor->value() == string(vm::docker));
        }
    }
}
