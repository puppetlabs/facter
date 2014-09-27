#include <gmock/gmock.h>
#include <facter/facts/collection.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include "../../fixtures.hpp"
#include <sstream>

using namespace std;
using namespace facter::facts;

TEST(facter_facts_posix_collection, resolve_external) {
    collection facts;
    ASSERT_EQ(0u, facts.size());
    ASSERT_TRUE(facts.empty());
    facts.add_external_facts({
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution",
    });
    ASSERT_FALSE(facts.empty());
    ASSERT_EQ(3u, facts.size());
    ASSERT_NE(nullptr, facts.get<string_value>("exe_fact1"));
    ASSERT_NE(nullptr, facts.get<string_value>("exe_fact2"));
    ASSERT_EQ(nullptr, facts.get<string_value>("exe_fact3"));
    ASSERT_NE(nullptr, facts.get<string_value>("exe_fact4"));
}
