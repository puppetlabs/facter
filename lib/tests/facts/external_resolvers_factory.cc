#include <catch.hpp>
#include <facter/facts/external_resolvers_factory.hpp>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::facts;

SCENARIO("checking common external file resolvers factory") {
    external_resolvers_factory erf;
    GIVEN("a file with unknown extension") {
        THEN("should throw no resolver exception") {
            REQUIRE_THROWS_AS(erf.get_resolver("foo.bin"), external::external_fact_no_resolver&);
        }
    }
    GIVEN("a JSON file extension") {
        THEN("it should be able to resolve") {
            REQUIRE(erf.get_resolver("foo.json"));
            REQUIRE(erf.get_resolver("FoO.jsOn"));
        }
    }
    GIVEN("a text file extension") {
        THEN("it should be able to resolve") {
            REQUIRE(erf.get_resolver("foo.txt"));
            REQUIRE(erf.get_resolver("FoO.TxT"));
        }
    }
    GIVEN("a YAML file extension") {
        THEN("it should be able to resolve") {
            REQUIRE(erf.get_resolver("foo.yaml"));
            REQUIRE(erf.get_resolver("FoO.yAmL"));
        }
    }
}
