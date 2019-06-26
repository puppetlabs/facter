#include <catch.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <internal/facts/linux/filesystem_resolver.hpp>
#include "../../collection_fixture.hpp"
#include <sstream>

using namespace std;
using namespace facter::facts::linux;
using namespace facter::testing;

SCENARIO("blkid output with non-printable ASCII characters") {
    REQUIRE(filesystem_resolver::safe_convert("") == "");
    REQUIRE(filesystem_resolver::safe_convert("hello") == "hello");
    REQUIRE(filesystem_resolver::safe_convert("\"hello\"") == "\\\"hello\\\"");
    REQUIRE(filesystem_resolver::safe_convert("\\hello\\") == "\\\\hello\\\\");
    REQUIRE(filesystem_resolver::safe_convert("i am \xE0\xB2\xA0\x5F\xE0\xB2\xA0") == "i am M-`M-2M- _M-`M-2M- ");
}

SCENARIO("using the filesystem resolver") {
  // Create fact struct to store results
  collection_fixture facts;
  WHEN("populating facts") {
    // Add filesystem resolver
    facts.add(make_shared<filesystem_resolver>());
    THEN("filesystem, mountpoints, and partition facts should resolve") {
      REQUIRE(facts.size() != 0u);
      REQUIRE(facts.query<facter::facts::string_value>("filesystems"));
      REQUIRE(facts.query<facter::facts::map_value>("mountpoints"));
      REQUIRE(facts.query<facter::facts::map_value>("partitions"));
    }
    THEN("non-tmpfs proc and sys mounts should not exist") {
      REQUIRE_FALSE(facts.query<facter::facts::map_value>("mountpoints./proc/"));
      REQUIRE_FALSE(facts.query<facter::facts::map_value>("mountpoints./sys/"));
    }
    THEN("non-tmpfs mounts should exist") {
      REQUIRE(facts.query<facter::facts::map_value>("mountpoints./"));
    }
  }
}
