#include <catch.hpp>
#include <internal/facts/resolvers/virtualization_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/vm.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct empty_virtualization_resolver : virtualization_resolver
{
 protected:
    string get_hypervisor(collection& facts) override
    {
        return "";
    }
};

struct unknown_hypervisor_resolver : virtualization_resolver
{
 protected:
    string get_hypervisor(collection& facts) override
    {
        return "foobar";
    }
};

struct unknown_non_virtual_hypervisor_resolver : virtualization_resolver
{
 protected:
    string get_hypervisor(collection& facts) override
    {
        return "foobar";
    }

    bool is_virtual(string const& hypervisor) override
    {
        return hypervisor != "foobar";
    }
};

struct known_hypervisor_resolver : virtualization_resolver
{
 protected:
    string get_hypervisor(collection& facts) override
    {
        return vm::docker;
    }
};

struct matched_product_hypervisor_resolver : virtualization_resolver
{
 protected:
    string get_hypervisor(collection& facts) override
    {
        facts.add(fact::product_name, make_value<string_value>("VMware"));
        auto result = get_fact_vm(facts);
        facts.remove(fact::product_name);
        return result;
    }
};

struct matched_vendor_hypervisor_resolver : virtualization_resolver
{
 protected:
    string get_hypervisor(collection& facts) override
    {
        facts.add(fact::bios_vendor, make_value<string_value>("Amazon EC2"));
        auto result = get_fact_vm(facts);
        facts.remove(fact::bios_vendor);
        return result;
    }
};

SCENARIO("using the virtualization resolver") {
    collection_fixture facts;
    WHEN("no hypervisor is returned") {
        facts.add(make_shared<empty_virtualization_resolver>());
        THEN("the system is reported as physical") {
            REQUIRE(facts.size() == 2u);
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
            REQUIRE(facts.size() == 2u);
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
            REQUIRE(facts.size() == 2u);
            auto is_virt = facts.get<boolean_value>(fact::is_virtual);
            REQUIRE(is_virt);
            REQUIRE_FALSE(is_virt->value());
            auto hypervisor = facts.get<string_value>(fact::virtualization);
            REQUIRE(hypervisor);
            REQUIRE(hypervisor->value() == "foobar");
        }
    }
    WHEN("a known hypervisor is returned") {
        facts.add(make_shared<known_hypervisor_resolver>());
        THEN("the system is reported as virtual") {
            REQUIRE(facts.size() == 2u);
            auto is_virt = facts.get<boolean_value>(fact::is_virtual);
            REQUIRE(is_virt);
            REQUIRE(is_virt->value());
            auto hypervisor = facts.get<string_value>(fact::virtualization);
            REQUIRE(hypervisor);
            REQUIRE(hypervisor->value() == string(vm::docker));
        }
    }

    WHEN("a hypervisor is matched from product name") {
        facts.add(make_shared<matched_product_hypervisor_resolver>());
        THEN("the system is reported as virtual") {
            REQUIRE(facts.size() == 2u);
            auto is_virt = facts.get<boolean_value>(fact::is_virtual);
            REQUIRE(is_virt);
            REQUIRE(is_virt->value());
            auto hypervisor = facts.get<string_value>(fact::virtualization);
            REQUIRE(hypervisor);
            REQUIRE(hypervisor->value() == string(vm::vmware));
        }
    }
    WHEN("a hypervisor is matched from the vendor name") {
        facts.add(make_shared<matched_vendor_hypervisor_resolver>());
        auto is_virt = facts.get<boolean_value>(fact::is_virtual);
        REQUIRE(is_virt);
        REQUIRE(is_virt->value());
        auto hypervisor = facts.get<string_value>(fact::virtualization);
        REQUIRE(hypervisor);
        REQUIRE(hypervisor->value() == string(vm::kvm));
    }
}
