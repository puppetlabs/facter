#include <catch.hpp>
#include <internal/facts/resolvers/xen_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/array_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct empty_xen_resolver : xen_resolver
{
 protected:
    virtual string xen_command() override
    {
        return "";
    }

    virtual data collect_data(collection& facts) override
    {
        data result;
        return result;
    }
};

struct test_xen_resolver : xen_resolver
{
 protected:
    virtual string xen_command() override
    {
        return "";
    }

    virtual data collect_data(collection& facts) override
    {
        data result;
        result.domains = { "domain1", "domain2" };
        return result;
    }
};

// CATCH doesn't behave well with constexpr, so create memory for
// the string here before using it in the test.
constexpr static char const* xen_privileged = vm::xen_privileged;

SCENARIO("using the Xen resolver on a privileged VM") {
    collection_fixture facts;
    facts.add(fact::virtualization, make_value<string_value>(xen_privileged));
    WHEN("data is not present") {
        facts.add(make_shared<empty_xen_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 1u);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_xen_resolver>());
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 3u);
            auto value = facts.get<string_value>(fact::xendomains);
            REQUIRE(value);
            REQUIRE(value->value() == "domain1,domain2");
        }

        THEN("structured facts are added") {
            REQUIRE(facts.size() == 3u);
            auto xen = facts.get<map_value>(fact::xen);
            REQUIRE(xen);
            REQUIRE(xen->size() == 1u);
            auto domains = xen->get<array_value>("domains");
            REQUIRE(domains);
            REQUIRE(domains->size() == 2u);
            for (size_t i = 0; i < 2; ++i) {
                auto domain = domains->get<string_value>(i);
                REQUIRE(domain);
                REQUIRE(domain->value() == "domain" + to_string(i+1));
            }
        }
    }
}

SCENARIO("using the Xen resolver on an unprivileged machine") {
    collection_fixture facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_xen_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_xen_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
}
