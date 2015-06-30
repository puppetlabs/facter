#include <catch.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/util/environment.hpp>
#include "../fixtures.hpp"
#include <sstream>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::testing;

struct simple_resolver : facter::facts::resolver
{
    simple_resolver() : resolver("test", { "foo" })
    {
    }

    virtual void resolve(collection& facts) override
    {
        facts.add("foo", make_value<string_value>("bar"));
    }
};

struct multi_resolver : facter::facts::resolver
{
    multi_resolver() : resolver("test", { "foo", "bar" })
    {
    }

    virtual void resolve(collection& facts) override
    {
        facts.add("foo", make_value<string_value>("bar"));
        facts.add("bar", make_value<string_value>("foo"));
    }
};

struct temp_variable
{
    temp_variable(string name, string const& value) :
        _name(move(name))
    {
        environment::set(_name, value);
    }

    ~temp_variable()
    {
        environment::clear(_name);
    }

    string _name;
};

SCENARIO("using the fact collection") {
    collection_fixture facts;
    REQUIRE(facts.size() == 0u);
    REQUIRE(facts.empty());

    GIVEN("default facts") {
        facts.add_default_facts(true);
        THEN("facts should resolve") {
            REQUIRE(facts.size() > 0u);
            REQUIRE_FALSE(facts.empty());
        }
    }
    GIVEN("a hidden fact and a revealed fact") {
        facts.add("foo", make_value<string_value>("bar"));
        facts.add("hidden_foo", make_value<string_value>("hidden_bar", true));
        THEN("they should be in the collection") {
            REQUIRE(facts.size() == 2u);
            REQUIRE_FALSE(facts.empty());
            auto fact = facts.get<string_value>("foo");
            REQUIRE(fact);
            REQUIRE(fact->value() == "bar");
            fact = dynamic_cast<string_value const *>(facts["foo"]);
            REQUIRE(fact);
            REQUIRE(fact->value() == "bar");
            auto hidden_fact = facts.get<string_value>("hidden_foo");
            REQUIRE(hidden_fact);
            REQUIRE(hidden_fact->value() == "hidden_bar");
            hidden_fact = dynamic_cast<string_value const *>(facts["hidden_foo"]);
            REQUIRE(hidden_fact);
            REQUIRE(hidden_fact->value() == "hidden_bar");
        }
        WHEN("writing default facts") {
            THEN("it should serialize the revealed fact to JSON") {
                ostringstream ss;
                facts.write(ss, format::json);
                REQUIRE(ss.str() == "{\n  \"foo\": \"bar\"\n}");
            }
            THEN("it should serialize the revealed fact to YAML") {
                ostringstream ss;
                facts.write(ss, format::yaml);
                REQUIRE(ss.str() == "foo: bar");
            }
            THEN("it should serialize the revealed fact to text") {
                ostringstream ss;
                facts.write(ss, format::hash);
                REQUIRE(ss.str() == "foo => bar");
            }
        }
        WHEN("writing all (hidden) facts") {
            THEN("it should serialize both facts to JSON") {
                ostringstream ss;
                facts.write(ss, format::json, {}, true);
                REQUIRE(ss.str() == "{\n  \"foo\": \"bar\",\n  \"hidden_foo\": \"hidden_bar\"\n}");
            }
            THEN("it should serialize both facts to YAML") {
                ostringstream ss;
                facts.write(ss, format::yaml, {}, true);
                REQUIRE(ss.str() == "foo: bar\nhidden_foo: hidden_bar");
            }
            THEN("it should serialize both facts to text") {
                ostringstream ss;
                facts.write(ss, format::hash, {}, true);
                REQUIRE(ss.str() == "foo => bar\nhidden_foo => hidden_bar");
            }
        }
        WHEN("querying facts") {
            THEN("it should serialize both facts to JSON") {
                ostringstream ss;
                facts.write(ss, format::json, {"foo", "hidden_foo"});
                REQUIRE(ss.str() == "{\n  \"foo\": \"bar\",\n  \"hidden_foo\": \"hidden_bar\"\n}");
            }
            THEN("it should serialize both facts to YAML") {
                ostringstream ss;
                facts.write(ss, format::yaml, {"foo", "hidden_foo"});
                REQUIRE(ss.str() == "foo: bar\nhidden_foo: hidden_bar");
            }
            THEN("it should serialize both facts to text") {
                ostringstream ss;
                facts.write(ss, format::hash, {"foo", "hidden_foo"});
                REQUIRE(ss.str() == "foo => bar\nhidden_foo => hidden_bar");
            }
        }
        WHEN("querying hidden facts") {
            THEN("it should serialize both facts to JSON") {
                ostringstream ss;
                facts.write(ss, format::json, {"foo", "hidden_foo"}, true);
                REQUIRE(ss.str() == "{\n  \"foo\": \"bar\",\n  \"hidden_foo\": \"hidden_bar\"\n}");
            }
            THEN("it should serialize both facts to YAML") {
                ostringstream ss;
                facts.write(ss, format::yaml, {"foo", "hidden_foo"}, true);
                REQUIRE(ss.str() == "foo: bar\nhidden_foo: hidden_bar");
            }
            THEN("it should serialize both facts to text") {
                ostringstream ss;
                facts.write(ss, format::hash, {"foo", "hidden_foo"}, true);
                REQUIRE(ss.str() == "foo => bar\nhidden_foo => hidden_bar");
            }
        }
    }
    GIVEN("a resolver that adds a single fact") {
        facts.add(make_shared<simple_resolver>());
        THEN("it should resolve facts into the collection") {
            REQUIRE(facts.size() == 1u);
            REQUIRE_FALSE(facts.empty());
            auto fact = facts.get<string_value>("foo");
            REQUIRE(fact);
            REQUIRE(fact->value() == "bar");
            fact = dynamic_cast<string_value const *>(facts["foo"]);
            REQUIRE(fact);
            REQUIRE(fact->value() == "bar");
        }
        WHEN("serializing to JSON") {
            THEN("it should contain the same values") {
                ostringstream ss;
                facts.write(ss, format::json);
                REQUIRE(ss.str() == "{\n  \"foo\": \"bar\"\n}");
            }
        }
        WHEN("serializing to YAML") {
            THEN("it should contain the same values") {
                ostringstream ss;
                facts.write(ss, format::yaml);
                REQUIRE(ss.str() == "foo: bar");
            }
        }
        WHEN("serializing to text") {
            GIVEN("only a single query") {
                THEN("it should output only the value") {
                    ostringstream ss;
                    facts.write(ss, format::hash, {"foo"});
                    REQUIRE(ss.str() == "bar");
                }
            }
            GIVEN("no queries") {
                THEN("it should contain the same values") {
                    ostringstream ss;
                    facts.write(ss, format::hash);
                    REQUIRE(ss.str() == "foo => bar");
                }
            }
        }
    }
    GIVEN("a resolver that adds multiple facts") {
        facts.add(make_shared<multi_resolver>());
        THEN("it should enumerate the facts in order") {
            int index = 0;
            facts.each([&](string const &name, value const *val) {
                auto string_val = dynamic_cast<string_value const *>(val);
                REQUIRE(string_val);
                if (index == 0) {
                    REQUIRE(name == "bar");
                    REQUIRE(string_val->value() == "foo");
                } else if (index == 1) {
                    REQUIRE(name == "foo");
                    REQUIRE(string_val->value() == "bar");
                } else {
                    FAIL("should not be reached");
                }
                ++index;
                return true;
            });
        }
        WHEN("serializing to JSON") {
            THEN("it should contain the same values") {
                ostringstream ss;
                facts.write(ss, format::json);
                REQUIRE(ss.str() == "{\n  \"bar\": \"foo\",\n  \"foo\": \"bar\"\n}");
            }
        }
        WHEN("serializing to YAML") {
            THEN("it should contain the same values") {
                ostringstream ss;
                facts.write(ss, format::yaml);
                REQUIRE(ss.str() == "bar: foo\nfoo: bar");
            }
        }
        WHEN("serializing to text") {
            THEN("it should contain the same values") {
                ostringstream ss;
                facts.write(ss, format::hash);
                REQUIRE(ss.str() == "bar => foo\nfoo => bar");
            }
        }
    }
    GIVEN("external facts paths to search") {
        facts.add_external_facts({
                LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/yaml",
                LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/json",
                LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/text",
        });
        REQUIRE_FALSE(facts.empty());
        REQUIRE(facts.size() == 17u);
        WHEN("YAML files are present") {
            THEN("facts should be added") {
                REQUIRE(facts.get<string_value>("yaml_fact1"));
                REQUIRE(facts.get<integer_value>("yaml_fact2"));
                REQUIRE(facts.get<boolean_value>("yaml_fact3"));
                REQUIRE(facts.get<double_value>("yaml_fact4"));
                REQUIRE(facts.get<array_value>("yaml_fact5"));
                REQUIRE(facts.get<map_value>("yaml_fact6"));
                REQUIRE(facts.get<string_value>("yaml_fact7"));
            }
        }
        WHEN("JSON files are present") {
            THEN("facts should be added") {
                REQUIRE(facts.get<string_value>("json_fact1"));
                REQUIRE(facts.get<integer_value>("json_fact2"));
                REQUIRE(facts.get<boolean_value>("json_fact3"));
                REQUIRE(facts.get<double_value>("json_fact4"));
                REQUIRE(facts.get<array_value>("json_fact5"));
                REQUIRE(facts.get<map_value>("json_fact6"));
                REQUIRE(facts.get<string_value>("json_fact7"));
            }
        }
        WHEN("text files are present") {
            THEN("facts should be added") {
                REQUIRE(facts.get<string_value>("txt_fact1"));
                REQUIRE(facts.get<string_value>("txt_fact2"));
                REQUIRE_FALSE(facts.get<string_value>("txt_fact3"));
                REQUIRE(facts.get<string_value>("txt_fact4"));
            }
        }
    }
    GIVEN("structured fact data") {
        auto map = make_value<map_value>();
        map->add("string", make_value<string_value>("hello"));
        map->add("integer", make_value<integer_value>(5));
        map->add("double", make_value<double_value>(0.3));
        map->add("boolean", make_value<boolean_value>(true));
        auto submap = make_value<map_value>();
        submap->add("foo", make_value<string_value>("bar"));
        map->add("submap", move(submap));
        submap = make_value<map_value>();
        submap->add("jam", make_value<string_value>("cakes"));
        map->add("name.with.dots", move(submap));
        auto array = make_value<array_value>();
        array->add(make_value<string_value>("foo"));
        array->add(make_value<integer_value>(10));
        array->add(make_value<double_value>(2.3));
        array->add(make_value<boolean_value>(false));
        submap = make_value<map_value>();
        submap->add("bar", make_value<string_value>("baz"));
        array->add(move(submap));
        map->add("array", move(array));
        facts.add("map", move(map));
        facts.add("string", make_value<string_value>("world"));

        WHEN("queried with a matching top level name") {
            THEN("a value should be returned") {
                auto mvalue = facts.query<map_value>("map");
                REQUIRE(mvalue);
                REQUIRE(mvalue->size() == 7u);
            }
        }
        WHEN("queried with a non-matching top level name") {
            THEN("it should return null") {
                REQUIRE_FALSE(facts.query<string_value>("does not exist"));
            }
        }
        WHEN("querying for a sub element of a type that is not a map") {
            THEN("it should return null") {
                REQUIRE_FALSE(facts.query<string_value>("string.foo"));
            }
        }
        WHEN("queried with for a sub element") {
            THEN("a value should be returned") {
                auto svalue = facts.query<string_value>("map.string");
                REQUIRE(svalue);
                REQUIRE(svalue->value() == "hello");
                auto ivalue = facts.query<integer_value>("map.integer");
                REQUIRE(ivalue);
                REQUIRE(ivalue->value() == 5);
                auto dvalue = facts.query<double_value>("map.double");
                REQUIRE(dvalue);
                REQUIRE(dvalue->value() == Approx(0.3));
                auto bvalue = facts.query<boolean_value>("map.boolean");
                REQUIRE(bvalue);
                REQUIRE(bvalue->value());
                auto mvalue = facts.query<map_value>("map.submap");
                REQUIRE(mvalue);
                REQUIRE(mvalue->size() == 1u);
            }
        }
        WHEN("querying along a path of map values") {
            THEN("a value should be returned") {
                auto svalue = facts.query<string_value>("map.submap.foo");
                REQUIRE(svalue);
                REQUIRE(svalue->value() == "bar");
            }
        }
        WHEN("querying into an array with an in-bounds index") {
            THEN("a value should be returned") {
                auto avalue = facts.query<array_value>("map.array");
                REQUIRE(avalue);
                REQUIRE(avalue->size() == 5u);
                for (size_t i = 0; i < avalue->size(); ++i) {
                    REQUIRE(facts.query("map.array." + to_string(i)));
                }
            }
        }
        WHEN("querying into an array with a non-numeric index") {
            THEN("it should return null") {
                REQUIRE_FALSE(facts.query("map.array.foo"));
            }
        }
        WHEN("uerying into an array with an out-of-bounds index") {
            THEN("it should return null") {
                REQUIRE_FALSE(facts.query("map.array.5"));
            }
        }
        WHEN("querying into an element inside of an array") {
            THEN("it should return a value") {
                auto svalue = facts.query<string_value>("map.array.4.bar");
                REQUIRE(svalue);
                REQUIRE(svalue->value() == "baz");
            }
        }
        WHEN("a fact name contains dots") {
            THEN("it not reqturn a value unless quoted") {
                REQUIRE_FALSE(facts.query("map.name.with.dots"));
            }
            THEN("it should return a value when quoted") {
                auto svalue = facts.query<string_value>("map.\"name.with.dots\".jam");
                REQUIRE(svalue);
                REQUIRE(svalue->value() == "cakes");
            }
        }
    }
    GIVEN("a fact from an environment variable") {
        auto var = temp_variable("FACTER_Foo", "bar");
        bool added = false;
        facts.add_environment_facts([&](string const& name) {
            added = name == "foo";
        });
        REQUIRE(added);

        THEN("the fact should be present in the collection") {
            REQUIRE(facts.size() == 1u);
            auto value = facts.get<string_value>("foo");
            REQUIRE(value);
            REQUIRE(value->value() == "bar");
        }
    }
    GIVEN("a fact from an environment with the same name as a built-in fact") {
        facts.add_default_facts(true);
        auto var = temp_variable("FACTER_KERNEL", "overridden");
        bool added = false;
        facts.add_environment_facts([&](string const& name) {
            added = name == "kernel";
        });
        REQUIRE(added);

        THEN("it should override the built-in fact's value") {
            auto value = facts.get<string_value>("kernel");
            REQUIRE(value);
            REQUIRE(value->value() == "overridden");
        }
    }
    GIVEN("two external fact directories to search") {
        facts.add_external_facts({
            LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/ordering/foo",
            LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/ordering/bar"
        });
        THEN("it should have the fact value from the last file loaded") {
            REQUIRE(facts.size() == 1u);
            REQUIRE(facts.get<string_value>("foo"));
            REQUIRE(facts.get<string_value>("foo")->value() == "set in bar/foo.yaml");
        }
        facts.clear();
        facts.add_external_facts({
            LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/ordering/bar",
            LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/ordering/foo"
        });
        THEN("it should have the fact value from the last file loaded") {
            REQUIRE(facts.size() == 1u);
            REQUIRE(facts.get<string_value>("foo"));
            REQUIRE(facts.get<string_value>("foo")->value() == "set in foo/foo.yaml");
        }
    }
}

class collection_override : public collection
{
 protected:
    virtual vector<string> get_external_fact_directories() const override
    {
        return {LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/ordering/foo"};
    }
};

SCENARIO("using the fact collection with a default external fact path") {
    collection_override facts;
    REQUIRE(facts.size() == 0u);
    REQUIRE(facts.empty());

    GIVEN("a specified external fact directory with an overriding fact to search") {
        facts.add_external_facts({
            LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/ordering/bar"
        });
        THEN("it should have the fact value from the last file loaded") {
            REQUIRE(facts.size() == 1u);
            REQUIRE(facts.get<string_value>("foo"));
            REQUIRE(facts.get<string_value>("foo")->value() == "set in bar/foo.yaml");
        }
    }

    GIVEN("a specified external fact directory with new facts to search") {
        facts.add_external_facts({
            LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/text",
        });
        REQUIRE_FALSE(facts.empty());
        REQUIRE(facts.size() == 4);
        THEN("facts from both directories should be added") {
            REQUIRE(facts.get<string_value>("foo"));
            REQUIRE(facts.get<string_value>("txt_fact1"));
            REQUIRE(facts.get<string_value>("txt_fact2"));
            REQUIRE_FALSE(facts.get<string_value>("txt_fact3"));
            REQUIRE(facts.get<string_value>("txt_fact4"));
        }
    }
}
