#define CATCH_CONFIG_RUNNER
#include <catch.hpp>
#include <internal/ruby/api.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/nowide/iostream.hpp>

using namespace std;
using namespace facter::ruby;
using namespace leatherman::logging;

int main(int argc, char **argv)
{
   // Disable logging for tests
    set_level(log_level::none);

    // Uncomment this to get debug output during a test run
    // setup_logging(cout);
    // set_level(log_level::debug);

    // Before running tests, initialize Ruby
    auto ruby = api::instance();
    if (ruby) {
        ruby->initialize();
    }

    return Catch::Session().run( argc, argv );
}
