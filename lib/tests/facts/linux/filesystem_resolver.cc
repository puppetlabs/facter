#include <catch.hpp>
#include <internal/facts/linux/filesystem_resolver.hpp>

using namespace std;
using namespace facter::facts::linux;

SCENARIO("blkid output with non-printable ASCII characters") {
    REQUIRE(filesystem_resolver::safe_convert("") == "");
    REQUIRE(filesystem_resolver::safe_convert("hello") == "hello");
    REQUIRE(filesystem_resolver::safe_convert("\"hello\"") == "\\\"hello\\\"");
    REQUIRE(filesystem_resolver::safe_convert("\\hello\\") == "\\\\hello\\\\");
    REQUIRE(filesystem_resolver::safe_convert("i am \xE0\xB2\xA0\x5F\xE0\xB2\xA0") == "i am M-`M-2M- _M-`M-2M- ");
}
