#include <catch.hpp>
#include <leatherman/ruby/api.hpp>
#include <internal/ruby/ruby_value.hpp>
#include "../ruby_helper.hpp"
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::testing;
using namespace facter::ruby;
using namespace leatherman::ruby;

SCENARIO("Windows custom facts written in Ruby") {
    collection_fixture facts;
    REQUIRE(facts.size() == 0u);

    // Setup ruby
    auto& ruby = api::instance();
    REQUIRE(ruby.initialized());
    ruby.include_stack_trace(true);

    GIVEN("a fact that loads win32ole") {
        REQUIRE(load_custom_fact("windows/ole.rb", facts));
        THEN("the value should be in the collection") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
        }
    }
}
