#define CATCH_CONFIG_RUNNER
#include <catch.hpp>
#include <facter/ruby/ruby.hpp>
#include <facter/logging/logging.hpp>
#include <boost/nowide/iostream.hpp>

using namespace std;
using namespace facter::logging;

int main(int argc, char **argv)
{
    // Disable logging for tests
    setup_logging(boost::nowide::cout);
    set_level(level::none);

    // Before running tests, initialize Ruby
    facter::ruby::initialize();

    return Catch::Session().run( argc, argv );
}
