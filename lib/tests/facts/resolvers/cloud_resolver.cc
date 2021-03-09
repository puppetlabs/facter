#include <catch.hpp>
#include <internal/facts/resolvers/cloud_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/vm.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct empty_cloud_resolver : cloud_resolver
{
 protected:
    string get_azure(collection& facts) override
    {
        return "";
    }
};

struct azure_cloud_resolver : cloud_resolver
{
 protected:
    string get_azure(collection& facts) override
    {
        return "azure";
    }
};

SCENARIO("using the cloud resolver") {
    collection_fixture facts;
    WHEN("no cloud provider is returned") {
        facts.add(make_shared<empty_cloud_resolver>());
        THEN("the cloud fact is not populated") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("a cloud provider is returned") {
        facts.add(make_shared<azure_cloud_resolver>());
        THEN("the cloud fact is populated") {
            REQUIRE(facts.size() == 1u);
            auto cloud = facts.get<map_value>(fact::cloud);
            REQUIRE(cloud);
            REQUIRE(cloud->size() == 1u);
            auto provider = cloud->get<string_value>("provider");
            REQUIRE(provider->value() == "azure");
        }
    }
}
