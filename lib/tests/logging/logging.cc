#include <catch.hpp>
#include <facter/logging/logging.hpp>
#include <leatherman/util/regex.hpp>
#include "../log_capture.hpp"

using namespace std;
using namespace facter::logging;
using namespace leatherman::util;
using namespace facter::testing;

SCENARIO("logging with a TRACE level") {
    log_capture capture(level::trace);
    REQUIRE(is_enabled(level::trace));
    log(level::trace, "testing {1} {2} {3}", 1, "2", 3.0);
    auto output = capture.result();
    CAPTURE(output);
    REQUIRE(re_search(output, boost::regex("TRACE puppetlabs\\.facter - testing 1 2 3$")));
    REQUIRE_FALSE(error_logged());
}

SCENARIO("logging with a DEBUG level") {
    log_capture capture(level::debug);
    REQUIRE(is_enabled(level::debug));
    log(level::debug, "testing {1} {2} {3}", 1, "2", 3.0);
    auto output = capture.result();
    CAPTURE(output);
    REQUIRE(re_search(output, boost::regex("DEBUG puppetlabs\\.facter - testing 1 2 3$")));
    REQUIRE_FALSE(error_logged());
}

SCENARIO("logging with an INFO level") {
    log_capture capture(level::info);
    REQUIRE(is_enabled(level::info));
    log(level::info, "testing {1} {2} {3}", 1, "2", 3.0);
    auto output = capture.result();
    CAPTURE(output);
    REQUIRE(re_search(output, boost::regex("INFO  puppetlabs\\.facter - testing 1 2 3$")));
    REQUIRE_FALSE(error_logged());
}

SCENARIO("logging with a WARNING level") {
    log_capture capture(level::warning);
    REQUIRE(is_enabled(level::warning));
    log(level::warning, "testing {1} {2} {3}", 1, "2", 3.0);
    auto output = capture.result();
    CAPTURE(output);
    REQUIRE(re_search(output, boost::regex("WARN  puppetlabs\\.facter - testing 1 2 3")));
    REQUIRE_FALSE(error_logged());
}

SCENARIO("logging with an ERROR level") {
    log_capture capture(level::error);
    REQUIRE(is_enabled(level::error));
    log(level::error, "testing {1} {2} {3}", 1, "2", 3.0);
    auto output = capture.result();
    CAPTURE(output);
    REQUIRE(re_search(output, boost::regex("ERROR puppetlabs\\.facter - testing 1 2 3$")));
    REQUIRE(error_logged());
}

SCENARIO("logging with a FATAL level") {
    log_capture capture(level::fatal);
    REQUIRE(is_enabled(level::fatal));
    log(level::fatal, "testing {1} {2} {3}", 1, "2", 3.0);
    auto output = capture.result();
    CAPTURE(output);
    REQUIRE(re_search(output, boost::regex("FATAL puppetlabs\\.facter - testing 1 2 3$")));
    REQUIRE(error_logged());
}
