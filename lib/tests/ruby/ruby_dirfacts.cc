#include <catch.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/ruby/ruby.hpp>
#include <internal/ruby/ruby_value.hpp>
#include <leatherman/ruby/api.hpp>
#include "../fixtures.hpp"
#include "../collection_fixture.hpp"
#include "./ruby_helper.hpp"

using namespace std;
using namespace facter::ruby;
using namespace facter::testing;
using namespace leatherman::ruby;

SCENARIO("directories of custom facts written in Ruby") {
    collection_fixture facts;
    REQUIRE(facts.size() == 0u);

    // Setup ruby
    auto& ruby = api::instance();
    REQUIRE(ruby.initialized());
    ruby.include_stack_trace(true);

    string fixtures = LIBFACTER_TESTS_DIRECTORY "/fixtures/ruby/";

    GIVEN("a fact that performs network activity") {
        load_custom_facts(facts, vector<string>{fixtures+"custom_dir"});
        THEN("the network location should resolve") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("sometest")) == "\"Yay\"");
        }
    }
}
