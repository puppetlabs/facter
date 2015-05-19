#include <catch.hpp>
#include <facter/util/option_set.hpp>

using namespace std;
using namespace facter::util;

enum class options
{
    foo = (1 << 0),
    bar = (1 << 1),
    baz = (1 << 2)
};

SCENARIO("using an option set") {
    GIVEN("a default constructed option set") {
        option_set<options> set;
        THEN("no options are set") {
            REQUIRE(set.count() == 0u);
            REQUIRE_FALSE(set[options::foo]);
            REQUIRE_FALSE(set[options::bar]);
            REQUIRE_FALSE(set[options::baz]);
        }
    }
    GIVEN("option foo is set") {
        option_set<options> set = { options::foo };
        THEN("only foo is set") {
            REQUIRE(set.count() == 1u);
            REQUIRE(set[options::foo]);
            REQUIRE_FALSE(set[options::bar]);
            REQUIRE_FALSE(set[options::baz]);
        }
    }
    GIVEN("options foo and bar are set") {
        option_set<options> set = { options::bar, options::foo };
        THEN("only foo and bar are set") {
            REQUIRE(set.count() == 2u);
            REQUIRE(set[options::foo]);
            REQUIRE(set[options::bar]);
            REQUIRE_FALSE(set[options::baz]);
        }
    }
    GIVEN("all options are specified") {
        option_set<options> set = { options::baz, options::foo, options::bar };
        THEN("all options are set") {
            REQUIRE(set.count() == 3u);
            REQUIRE(set[options::foo]);
            REQUIRE(set[options::bar]);
            REQUIRE(set[options::baz]);
        }
    }
    GIVEN("all options are set by numeric value") {
        option_set<options> set(1 | 2 | 4);
        THEN("all options are set") {
            REQUIRE(set.count() == 3u);
            REQUIRE(set[options::foo]);
            REQUIRE(set[options::bar]);
            REQUIRE(set[options::baz]);
        }
    }
    GIVEN("all options are set with set_all") {
        option_set<options> set;
        set.set_all();
        THEN("all options are set") {
            REQUIRE(set.count() == set.size());
            REQUIRE(set[options::foo]);
            REQUIRE(set[options::bar]);
            REQUIRE(set[options::baz]);
        }
    }
    GIVEN("an empty set") {
        option_set<options> set;
        REQUIRE(set.empty());
        WHEN("set is called with foo") {
            set.set(options::foo);
            THEN("foo is set") {
                REQUIRE(set[options::foo]);
                REQUIRE_FALSE(set[options::bar]);
                REQUIRE_FALSE(set[options::baz]);
            }
        }
        WHEN("set is called with bar") {
            set.set(options::bar);
            THEN("bar is set") {
                REQUIRE_FALSE(set[options::foo]);
                REQUIRE(set[options::bar]);
                REQUIRE_FALSE(set[options::baz]);
            }
        }
        WHEN("set is called with baz") {
            set.set(options::baz);
            THEN("baz is set") {
                REQUIRE_FALSE(set[options::foo]);
                REQUIRE_FALSE(set[options::bar]);
                REQUIRE(set[options::baz]);
            }
        }
        WHEN("reset is called") {
            set.reset();
            THEN("the set is still empty") {
                REQUIRE(set.count() == 0u);
                REQUIRE_FALSE(set[options::foo]);
                REQUIRE_FALSE(set[options::bar]);
                REQUIRE_FALSE(set[options::baz]);
            }
        }
        WHEN("toggle is called") {
            set.toggle();
            THEN("all options are set") {
                REQUIRE(set[options::foo]);
                REQUIRE(set[options::bar]);
                REQUIRE(set[options::baz]);
            }
        }
        WHEN("toggle is called on a particular option") {
            set.toggle(options::foo);
            THEN("the option should be set") {
                REQUIRE(set[options::foo]);
            }
            THEN("the count is one") {
                REQUIRE(set.count() == 1u);
            }
        }
        WHEN("toggle is called twice on a particular option") {
            set.toggle(options::foo);
            set.toggle(options::foo);
            THEN("the option should not be set") {
                REQUIRE_FALSE(set[options::foo]);
            }
            THEN("the count is zero") {
                REQUIRE(set.count() == 0u);
            }
        }
        THEN("the count is zero") {
            REQUIRE(set.count() == 0u);
        }
        THEN("the set is reports as empty") {
            REQUIRE(set.empty());
        }
        THEN("the size is the number of bits in an integer") {
            REQUIRE(set.size() == sizeof(int) * 8);
        }
        THEN("no option is set") {
            REQUIRE_FALSE(set.test(options::foo));
            REQUIRE_FALSE(set.test(options::bar));
            REQUIRE_FALSE(set.test(options::baz));
        }
    }
    GIVEN("an option set with all values set") {
        option_set<options> set = { options::foo, options::bar, options::baz };
        WHEN("clear is called with foo") {
            set.clear(options::foo);
            THEN("foo is not set") {
                REQUIRE_FALSE(set[options::foo]);
                REQUIRE(set[options::bar]);
                REQUIRE(set[options::baz]);
            }
        }
        WHEN("clear is called with bar") {
            set.clear(options::bar);
            THEN("bar is not set") {
                REQUIRE(set[options::foo]);
                REQUIRE_FALSE(set[options::bar]);
                REQUIRE(set[options::baz]);
            }
        }
        WHEN("clear is called with baz") {
            set.clear(options::baz);
            THEN("baz is not set") {
                REQUIRE(set[options::foo]);
                REQUIRE(set[options::bar]);
                REQUIRE_FALSE(set[options::baz]);
            }
        }
        WHEN("reset is called") {
            set.reset();
            THEN("the set is empty") {
                REQUIRE(set.count() == 0u);
                REQUIRE_FALSE(set[options::foo]);
                REQUIRE_FALSE(set[options::bar]);
                REQUIRE_FALSE(set[options::baz]);
            }
        }
        WHEN("toggle is called") {
            set.toggle();
            THEN("the set is empty options are set") {
                REQUIRE_FALSE(set[options::foo]);
                REQUIRE_FALSE(set[options::bar]);
                REQUIRE_FALSE(set[options::baz]);
            }
        }
        THEN("the count is three") {
            REQUIRE(set.count() == 3u);
        }
        THEN("the set is not empty") {
            REQUIRE_FALSE(set.empty());
        }
        THEN("all options are set") {
            REQUIRE(set.test(options::foo));
            REQUIRE(set.test(options::bar));
            REQUIRE(set.test(options::baz));
        }
    }
    GIVEN("two option sets") {
        option_set<options> set1 = { options::foo, options::bar };
        option_set<options> set2 = { options::bar, options::baz };
        WHEN("a third set is the result of bitwise AND") {
            option_set<options> set3 = set1 & set2;
            THEN("only the intersecting options are set") {
                REQUIRE(set3.count() == 1u);
                REQUIRE_FALSE(set3[options::foo]);
                REQUIRE(set3[options::bar]);
                REQUIRE_FALSE(set3[options::baz]);
            }
        }
        WHEN("a third set is the result of bitwise OR") {
            option_set<options> set3 = set1 | set2;
            THEN("the union of the options are set") {
                REQUIRE(set3.count() == 3u);
                REQUIRE(set3[options::foo]);
                REQUIRE(set3[options::bar]);
                REQUIRE(set3[options::baz]);
            }
        }
        WHEN("a third set is the result of bitwise XOR") {
            option_set<options> set3 = set1 ^ set2;
            THEN("options that are in one set but not the other are set") {
                REQUIRE(set3.count() == 2u);
                REQUIRE(set3[options::foo]);
                REQUIRE_FALSE(set3[options::bar]);
                REQUIRE(set3[options::baz]);
            }
        }
    }
}
