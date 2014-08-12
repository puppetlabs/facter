#include <gmock/gmock.h>
#include <facter/ruby/api.hpp>
#include <facter/logging/logging.hpp>

using namespace std;
using namespace facter::ruby;

int main(int argc, char **argv)
{
    // Setup Boost.Log
    facter::logging::configure_logging(facter::logging::log_level::warning, std::cout);

    // Before running tests, initialize Ruby
    auto ruby = api::instance();
    if (ruby) {
        ruby->initialize();
    }
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
