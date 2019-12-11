#include <catch.hpp>
#include <leatherman/ruby/api.hpp>
#include <leatherman/util/scoped_env.hpp>
#include <leatherman/util/environment.hpp>
#include <internal/ruby/ruby_value.hpp>
#include "../ruby_helper.hpp"
#include "../../collection_fixture.hpp"
#include "../../fixtures.hpp"

using namespace std;
using namespace facter::testing;
using namespace facter::ruby;
using namespace leatherman::ruby;
using namespace leatherman::util;

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

SCENARIO("Run command with space in path") {
    collection_fixture facts;
    REQUIRE(facts.size() == 0u);

    // Setup ruby
    auto& ruby = api::instance();
    REQUIRE(ruby.initialized());
    ruby.include_stack_trace(true);

    GIVEN("a directory with a space on the PATH") {
        string path;
        environment::get("PATH", path);
        scoped_env var("PATH", path + environment::get_path_separator() + LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/with space");
        environment::reload_search_paths();
        REQUIRE(load_custom_fact("command_with_space.rb", facts));
        THEN("the command should execute successfully") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
        }
    }
    environment::reload_search_paths();
}
