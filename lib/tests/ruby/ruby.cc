#include <catch.hpp>
#include <facter/version.h>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <internal/ruby/api.hpp>
#include <internal/ruby/module.hpp>
#include <internal/ruby/ruby_value.hpp>
#include <internal/util/regex.hpp>
#include <internal/util/scoped_env.hpp>
#include <leatherman/logging/logging.hpp>
#include "../fixtures.hpp"
#include "../log_capture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::ruby;
using namespace facter::util;
using namespace facter::logging;
using namespace facter::testing;

bool load_custom_fact(string const& filename, collection& facts)
{
    auto ruby = api::instance();

    module mod(facts);

    string file = LIBFACTER_TESTS_DIRECTORY "/fixtures/ruby/" + filename;
    VALUE result = ruby->rescue([&]() {
        // Do not construct C++ objects in a rescue callback
        // C++ stack unwinding will not take place if a Ruby exception is thrown!
        ruby->rb_load(ruby->utf8_value(file), 0);
        return ruby->true_value();
    }, [&](VALUE ex) {
        LOG_ERROR("error while resolving custom facts in %1%: %2%", file, ruby->exception_to_string(ex));
        return ruby->false_value();
    });

    mod.resolve_facts();

    return ruby->is_true(result);
}

string ruby_value_to_string(value const* value)
{
    ostringstream ss;
    if (value) {
        value->write(ss);
    }
    return ss.str();
}

SCENARIO("custom facts written in Ruby") {
    collection facts;
    REQUIRE(facts.size() == 0u);

    // Setup ruby
    auto ruby = api::instance();
    REQUIRE(ruby);
    REQUIRE(ruby->initialized());
    ruby->include_stack_trace(true);

    GIVEN("a fact that resolves to nil") {
        REQUIRE(load_custom_fact("nil_fact.rb", facts));
        THEN("the value should not be in the collection") {
            REQUIRE_FALSE(facts["foo"]);
        }
    }
    GIVEN("a fact that resolves to non-nil") {
        REQUIRE(load_custom_fact("simple.rb", facts));
        THEN("the value should be in the collection") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
        }
    }
    GIVEN("a fact with a simple resolution") {
        REQUIRE(load_custom_fact("simple_resolution.rb", facts));
        THEN("the value should be in the collection") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
        }
    }
    GIVEN("a fact without any resolutions") {
        WHEN("the fact has no explicit value") {
            REQUIRE(load_custom_fact("empty_fact.rb", facts));
            THEN("the value should not be in the collection") {
                REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("the fact has an explicit value") {
            REQUIRE(load_custom_fact("empty_fact_with_value.rb", facts));
            THEN("the value should be in the collection") {
                REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "{\n  int => 1,\n  bool_true => true,\n  bool_false => false,\n  double => 12.34,\n  string => \"foo\",\n  array => [\n    1,\n    2,\n    3\n  ]\n}");
            }
        }
    }
    GIVEN("a fact with an empty command") {
        log_capture capture(level::error);
        REQUIRE_FALSE(load_custom_fact("empty_command.rb", facts));
        THEN("an error is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - .* expected a non-empty String for first argument")));
        }
    }
    GIVEN("a fact with a command") {
        REQUIRE(load_custom_fact("simple_command.rb", facts));
        THEN("the value should be in the collection") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar baz\"");
        }
    }
    GIVEN("a fact with a bad command") {
        THEN("the value should not be in the collection") {
            REQUIRE_FALSE(facts["foo"]);
        }
    }
    GIVEN("a fact with unicode characters in the path and name") {
        REQUIRE(load_custom_fact("uni\u1401dir/customfacts\u2122.rb", facts));
        THEN("the value should be in the collection") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("somefact\u2122")) == "\"other\u2122\"");
        }
    }
    GIVEN("a fact with a confine") {
        WHEN("the confine is met") {
            facts.add("somefact", make_value<string_value>("SomeValue"));
            REQUIRE(load_custom_fact("simple_confine.rb", facts));
            THEN("the value should be in the collection") {
                REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
            }
        }
        WHEN("the confine is not met") {
            REQUIRE(load_custom_fact("simple_confine.rb", facts));
            THEN("the value should not be in the collection") {
                REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("the multiple confines are present and one is not met") {
            facts.add("kernel", make_value<string_value>("linux"));
            REQUIRE(load_custom_fact("confine_missing_fact.rb", facts));
            THEN("the value should not be in the collection") {
                REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("multiple confines are met") {
            facts.add("fact1", make_value<string_value>("VALUE1"));
            facts.add("fact2", make_value<string_value>("Value2"));
            facts.add("fact3", make_value<string_value>("value3"));
            REQUIRE(load_custom_fact("multi_confine.rb", facts));
            THEN("the value should be in the collection") {
                REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
            }
        }
        WHEN("none of the multiple confines are met") {
            REQUIRE(load_custom_fact("multi_confine.rb", facts));
            THEN("the value should not be in the collection") {
                REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("the confine is a block that returns nil") {
            REQUIRE(load_custom_fact("block_nil_confine.rb", facts));
            THEN("the value should not be in the collection") {
                REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("the confine is a block that evaluates to false") {
            REQUIRE(load_custom_fact("block_confine.rb", facts));
            THEN("the value should not be in the collection") {
                REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("the confine is a block that simply returns false") {
            REQUIRE(load_custom_fact("block_false_confine.rb", facts));
            THEN("the value should not be in the collection") {
                REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("the confine is a block that evaluates to true") {
            facts.add("fact1", make_value<string_value>("value1"));
            REQUIRE(load_custom_fact("block_confine.rb", facts));
            THEN("the value should be in the collection") {
                REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
            }
        }
        WHEN("the confine is a block that simply returns true") {
            REQUIRE(load_custom_fact("block_true_confine.rb", facts));
            THEN("the value should be in the collection") {
                REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
            }
        }
        WHEN("the confine is an array and the value is not in the array") {
            facts.add("fact", make_value<string_value>("foo"));
            REQUIRE(load_custom_fact("array_confine.rb", facts));
            THEN("the value should not be in the collection") {
                REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("the confine is an array and the value is in the array") {
            facts.add("fact", make_value<string_value>("value3"));
            REQUIRE(load_custom_fact("array_confine.rb", facts));
            THEN("the value should be in the collection") {
                REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
            }
        }
        WHEN("the confine is a regular expression that evaluates to true") {
            facts.add("fact", make_value<string_value>("foo"));
            REQUIRE(load_custom_fact("regexp_confine.rb", facts));
            THEN("the value should be in the collection") {
              REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
            }
        }
        WHEN("the confine is a regular expression that evaluates to false") {
            facts.add("fact", make_value<string_value>("baz"));
            REQUIRE(load_custom_fact("regexp_confine.rb", facts));
            THEN("the value should not be in the collection") {
              REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("the confine is a range that evaluates to true") {
            facts.add("fact", make_value<integer_value>(4));
            REQUIRE(load_custom_fact("range_confine.rb", facts));
            THEN("the value should be in the collection") {
              REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
            }
        }
        WHEN("the confine is a range that evaluates to false") {
            facts.add("fact", make_value<integer_value>(10));
            REQUIRE(load_custom_fact("range_confine.rb", facts));
            THEN("the value should not be in the collection") {
              REQUIRE_FALSE(facts["foo"]);
            }
        }
        WHEN("the confine evaluates to true") {
            facts.add("fact", make_value<boolean_value>(true));
            REQUIRE(load_custom_fact("boolean_true_confine.rb", facts));
            THEN("the value should be in the collection") {
                REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
            }
        }
        WHEN("the confine evaluates to false") {
            facts.add("fact", make_value<boolean_value>(true));
            REQUIRE(load_custom_fact("boolean_false_confine.rb", facts));
            THEN("the value should not be in the collection") {
                REQUIRE_FALSE(facts["foo"]);
            }
        }
        THEN("resolution with the most confines wins") {
            facts.add("fact1", make_value<string_value>("value1"));
            facts.add("fact2", make_value<string_value>("value2"));
            facts.add("fact3", make_value<string_value>("value3"));
            REQUIRE(load_custom_fact("confine_weight.rb", facts));
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"value2\"");
        }
    }
    GIVEN("a file with a syntax error") {
        log_capture capture(level::error);
        REQUIRE_FALSE(load_custom_fact("bad_syntax.rb", facts));
        THEN("an error is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - .* undefined method `foo' for Facter:Module")));
        }
    }
    GIVEN("a fact with weighted resolutions") {
        REQUIRE(load_custom_fact("weight.rb", facts));
        THEN("the resolution with the highest weight wins") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"value2\"");
        }
    }
    GIVEN("a fact with weight options") {
        REQUIRE(load_custom_fact("weight_option.rb", facts));
        THEN("the resolution with the highest weight wins") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"value2\"");
        }
    }
    GIVEN("a fact that resolves to a string value") {
        REQUIRE(load_custom_fact("string_fact.rb", facts));
        THEN("the value is a string") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"hello world\"");
        }
    }
    GIVEN("a fact that resolves to an integer value") {
        REQUIRE(load_custom_fact("integer_fact.rb", facts));
        THEN("the value is an integer") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "1234");
        }
    }
    GIVEN("a fact that resolves to a true value") {
        REQUIRE(load_custom_fact("boolean_true_fact.rb", facts));
        THEN("the value is true") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "true");
        }
    }
    GIVEN("a fact that resolves to a false value") {
        REQUIRE(load_custom_fact("boolean_false_fact.rb", facts));
        THEN("the value is false") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "false");
        }
    }
    GIVEN("a fact that resolves to a double value") {
        REQUIRE(load_custom_fact("double_fact.rb", facts));
        THEN("the value is a double") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "12.34");
        }
    }
    GIVEN("a fact that resolves to an array value") {
        REQUIRE(load_custom_fact("array_fact.rb", facts));
        THEN("the value is an array") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "[\n  1,\n  true,\n  false,\n  \"foo\",\n  12.4,\n  [\n    1\n  ],\n  {\n    foo => \"bar\"\n  }\n]");
        }
    }
    GIVEN("a fact that resolves to a hash value") {
        REQUIRE(load_custom_fact("hash_fact.rb", facts));
        THEN("the value is a hash") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "{\n  int => 1,\n  bool_true => true,\n  bool_false => false,\n  double => 12.34,\n  string => \"foo\",\n  array => [\n    1,\n    2,\n    3\n  ]\n}");
        }
    }
    GIVEN("a fact that resolves using Facter.value") {
        facts.add("bar", make_value<string_value>("baz"));
        REQUIRE(load_custom_fact("value.rb", facts));
        THEN("the value should match") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"baz\"");
        }
    }
    GIVEN("a fact that resolves using Facter.fact") {
        facts.add("bar", make_value<string_value>("baz"));
        REQUIRE(load_custom_fact("fact.rb", facts));
        THEN("the value should match") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"baz\"");
        }
    }
    GIVEN("a fact that resolves using Facter[]") {
        facts.add("bar", make_value<string_value>("baz"));
        REQUIRE(load_custom_fact("lookup.rb", facts));
        THEN("the value should match") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"baz\"");
        }
    }
    GIVEN("a fact that resolves when using Facter::Core::Execution#which") {
        REQUIRE(load_custom_fact("which.rb", facts));
        THEN("the value should match") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
        }
    }
    GIVEN("a fact that logs debug messages") {
        log_capture capture(level::debug);
        REQUIRE(load_custom_fact("debug.rb", facts));
        THEN("the messages should be logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("DEBUG puppetlabs\\.facter - message1")));
            REQUIRE(re_search(output, boost::regex("DEBUG puppetlabs\\.facter - message2")));
        }
    }
    GIVEN("a fact that logs debug messages only once") {
        log_capture capture(level::debug);
        REQUIRE(load_custom_fact("debugonce.rb", facts));
        THEN("the messages should be logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("DEBUG puppetlabs\\.facter - unique debug1")));
            REQUIRE(re_search(output, boost::regex("DEBUG puppetlabs\\.facter - unique debug2")));
        }
    }
    GIVEN("a fact that logs warning messages") {
        log_capture capture(level::warning);
        REQUIRE(load_custom_fact("warn.rb", facts));
        THEN("the messages should be logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - message1")));
            REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - message2")));
        }
    }
    GIVEN("a fact that logs warning messages only once") {
        log_capture capture(level::warning);
        REQUIRE(load_custom_fact("warnonce.rb", facts));
        THEN("the messages should be logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - unique warning1")));
            REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - unique warning2")));
        }
    }
    GIVEN("a fact that logs an exception") {
        log_capture capture(level::error);
        REQUIRE(load_custom_fact("log_exception.rb", facts));
        THEN("an error should be logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - first")));
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - second")));
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - third")));
        }
    }
    GIVEN("a fact with a named resolution") {
        REQUIRE(load_custom_fact("named_resolution.rb", facts));
        THEN("adding a resolution with the same name overrides the existing resolution") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"value2\"");
        }
    }
    GIVEN("a fact added with define_fact and define_resolution") {
        REQUIRE(load_custom_fact("define_fact.rb", facts));
        THEN("the value should be in the collection") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar\"");
        }
    }
    GIVEN("a fact with a dependency cycle") {
        log_capture capture(level::error);
        REQUIRE(load_custom_fact("cycle.rb", facts));
        THEN("an error is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - .* cycle detected while requesting value of fact \"bar\"")));
        }
    }
    GIVEN("an aggregate resolution with array chunks") {
        REQUIRE(load_custom_fact("aggregate.rb", facts));
        THEN("the arrays are appended") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "[\n  \"foo\",\n  \"bar\"\n]");
        }
    }
    GIVEN("an aggregate resolution with required chunks") {
        REQUIRE(load_custom_fact("aggregate_with_require.rb", facts));
        THEN("the arrays are appended in dependency order") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "[\n  \"foo\",\n  \"bar\",\n  \"foo\",\n  \"baz\",\n  \"foo\",\n  \"bar\",\n  \"foo\"\n]");
        }
    }
    GIVEN("an aggregate resolution with an invalid require") {
        log_capture capture(level::error);
        REQUIRE_FALSE(load_custom_fact("aggregate_invalid_require.rb", facts));
        THEN("the arrays are appended in dependency order") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - .* expected a Symbol or Array of Symbol for require option")));
        }
    }
    GIVEN("an aggregate resolution with a custom aggregator") {
        REQUIRE(load_custom_fact("aggregate_with_block.rb", facts));
        THEN("the value should be what was returned from the block") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "10");
        }
    }
    GIVEN("an aggregate resolution with hashes to merge") {
        REQUIRE(load_custom_fact("aggregate_with_merge.rb", facts));
        THEN("the value should be a deep merge of the hashes") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "{\n  foo => \"bar\",\n  array => [\n    1,\n    2,\n    3,\n    4,\n    5,\n    6\n  ],\n  hash => {\n    jam => \"cakes\",\n    subarray => [\n      \"hello\",\n      \"world\"\n    ],\n    foo => \"bar\"\n  },\n  baz => \"jam\"\n}");
        }
    }
    GIVEN("an aggregate resolution with an invalid require") {
        log_capture capture(level::error);
        REQUIRE(load_custom_fact("aggregate_with_invalid_merge.rb", facts));
        THEN("an error is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - .* cannot merge \"hello\":String and \"world\":String")));
        }
    }
    GIVEN("an aggregate resolution with a cycle") {
        log_capture capture(level::error);
        REQUIRE(load_custom_fact("aggregate_with_cycle.rb", facts));
        THEN("an error is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs.facter - .* chunk dependency cycle detected")));
        }
    }
    GIVEN("a fact with a defined aggregate resolution") {
        REQUIRE(load_custom_fact("define_aggregate_fact.rb", facts));
        THEN("value should be in the collection") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "[\n  \"foo\",\n  \"bar\"\n]");
        }
    }
    GIVEN("an aggregate resolution when a simple resolution already exists") {
        log_capture capture(level::error);
        REQUIRE_FALSE(load_custom_fact("existing_simple_resolution.rb", facts));
        THEN("an error is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - .* cannot define an aggregate resolution with name \"bar\": a simple resolution with the same name already exists")));
        }
    }
    GIVEN("a simple resolution when an aggregate resolution already exists") {
        log_capture capture(level::error);
        REQUIRE_FALSE(load_custom_fact("existing_aggregate_resolution.rb", facts));
        THEN("an error is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - .* cannot define a simple resolution with name \"bar\": an aggregate resolution with the same name already exists")));
        }
    }
    GIVEN("a custom fact that logs the facter version") {
        log_capture capture(level::debug);
        REQUIRE(load_custom_fact("version.rb", facts));
        THEN("the expected version is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("DEBUG puppetlabs\\.facter - " + (boost::format("%1%\\.%2%\\.%3%") % LIBFACTER_VERSION_MAJOR % LIBFACTER_VERSION_MINOR % LIBFACTER_VERSION_PATCH).str())));
        }
    }
    GIVEN("a fact resolution that uses Facter::Core::Execution#exec") {
        REQUIRE(load_custom_fact("exec.rb", facts));
        THEN("value should be in the collection") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"bar baz\"");
        }
    }
    GIVEN("Facter::Core::Execution#execute with on_fail => :raise") {
        log_capture capture(level::error);
        REQUIRE_FALSE(load_custom_fact("execute_on_fail_raise.rb", facts));
        THEN("an error is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - .* execution of command \"not a command\" failed")));
        }
    }
    GIVEN("a fact resolution that uses Facter::Core::Execution#execute with a default value") {
        REQUIRE(load_custom_fact("execute_on_fail_value.rb", facts));
        THEN("value should be in the collection") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "\"default\"");
        }
    }
    GIVEN("a fact resolution that uses Facter::Core::Execution#execute with a timeout") {
        log_capture capture(level::error);
        REQUIRE_FALSE(load_custom_fact("execute_timeout.rb", facts));
        THEN("an error is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - .* command timed out after 1 seconds")));
        }
    }
    GIVEN("a fact that uses timeout") {
        log_capture capture(level::warning);
        REQUIRE(load_custom_fact("timeout.rb", facts));
        THEN("a warning is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - timeout option is not supported for custom facts and will be ignored.$")));
            REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - timeout= is not supported for custom facts and will be ignored.$")));
        }
    }
    GIVEN("a fact that uses Facter#trace to enable backtraces") {
        log_capture capture(level::error);
        REQUIRE(load_custom_fact("trace.rb", facts));
        THEN("backtraces are logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - first")));
            REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - second\\nbacktrace:")));
        }
    }
    GIVEN("a fact that uses Facter#debugging to enable debug messages") {
        log_capture capture(level::debug);
        REQUIRE(load_custom_fact("debugging.rb", facts));
        THEN("debug message is logged") {
            auto output = capture.result();
            CAPTURE(output);
            REQUIRE(re_search(output, boost::regex("DEBUG puppetlabs\\.facter - yep")));
            REQUIRE_FALSE(re_search(output, boost::regex("DEBUG puppetlabs\\.facter - nope")));
        }
    }
    GIVEN("a custom on_message block") {
        log_capture capture(level::debug);
        REQUIRE(load_custom_fact("on_message.rb", facts));
        THEN("no messages are logged") {
            REQUIRE(capture.result().empty());
        }
    }
    GIVEN("a custom fact with a higher weight than a built-in fact") {
        REQUIRE(load_custom_fact("ruby.rb", facts));
        THEN("the custom fact wins") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("ruby")) == "\"override\"");
        }
    }
    GIVEN("a custom fact with the same weight as a built-in fact") {
        REQUIRE(load_custom_fact("facterversion.rb", facts));
        THEN("the built-in fact wins") {
            REQUIRE(ruby_value_to_string(facts["facterversion"]) == "\"" LIBFACTER_VERSION "\"");
        }
    }
    GIVEN("a fact value from the environment") {
        scoped_env var("FACTER_RuBy", "from environment!");
        REQUIRE(load_custom_fact("ruby.rb", facts));
        THEN("the value from the environment wins") {
            REQUIRE(ruby_value_to_string(facts["ruby"]) == "\"from environment!\"");
        }
    }
    GIVEN("a hash value with non-string keys") {
        REQUIRE(load_custom_fact("hash_with_non_string_key.rb", facts));
        THEN("the keys are converted to strings") {
            REQUIRE(ruby_value_to_string(facts.get<ruby_value>("foo")) == "{\n  foo => \"bar\"\n}");
        }
    }
}
