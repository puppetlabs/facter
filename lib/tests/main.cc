#include <gmock/gmock.h>
#include <facter/ruby/api.hpp>
#include <facter/logging/logging.hpp>
#include <boost/nowide/iostream.hpp>

using namespace std;
using namespace facter::ruby;
using namespace facter::logging;

int main(int argc, char **argv)
{
    try
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
    } catch (exception& ex) {
        boost::nowide::cerr << "Failure running tests: " << ex.what() << endl;
        return EXIT_FAILURE;
    }
}
