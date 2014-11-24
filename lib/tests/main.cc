#include <gmock/gmock.h>
#include <facter/ruby/api.hpp>
#include <facter/logging/logging.hpp>
#include "../inc/facter/logging/logging.hpp"

using namespace std;
using namespace facter::ruby;
using namespace facter::logging;

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
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
