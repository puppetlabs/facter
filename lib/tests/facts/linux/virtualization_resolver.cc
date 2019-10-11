#include <catch.hpp>
#include <facter/util/string.hpp>
#include <internal/facts/linux/virtualization_resolver.hpp>
#include "../../fixtures.hpp"
#include <iostream>

using namespace std;
using namespace facter::util;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

struct peek_resolver : linux::virtualization_resolver
{
    using virtualization_resolver::get_azure_from_leases_file;
};

SCENARIO("azure") {
    collection_fixture facts;

    WHEN("leases file does not exist") {
        auto result = peek_resolver::get_azure_from_leases_file("does-not-exist");
        THEN("azure is empty") {
            REQUIRE(result == "");
        }
    }

    WHEN("leases file contains 'option 245'") {
        auto result = peek_resolver::get_azure_from_leases_file(string(LIBFACTER_TESTS_DIRECTORY) + "/fixtures/facts/linux/cloud/azure");
        THEN("it reports azure") {
            REQUIRE(result == "azure");
        }
    }

    WHEN("leases file contains 'option unknown-245'") {
        auto result = peek_resolver::get_azure_from_leases_file(string(LIBFACTER_TESTS_DIRECTORY) + "/fixtures/facts/linux/cloud/azure-unknown");
        THEN("it reports azure") {
            REQUIRE(result == "azure");
        }
    }

    WHEN("leases file does not contain correct option") {
        auto result = peek_resolver::get_azure_from_leases_file(string(LIBFACTER_TESTS_DIRECTORY) + "/fixtures/facts/linux/cloud/not-azure");
        THEN("it does not report azure") {
            REQUIRE(result == "");
        }
    }
}
