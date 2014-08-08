#include <gmock/gmock.h>
#include <facter/ruby/api.hpp>
#include <facter/logging/logging.hpp>
#include <boost/log/support/date_time.hpp>
#include <boost/log/expressions/formatters/date_time.hpp>
#include <boost/log/utility/setup/console.hpp>
#include <boost/log/utility/setup/common_attributes.hpp>

using namespace std;
using namespace facter::ruby;
namespace expr = boost::log::expressions;
namespace logging = boost::log;

int main(int argc, char **argv)
{
    // Setup Boost.Log
    auto sink = logging::add_console_log(cout);

    sink->set_formatter(
        expr::stream
            << expr::format_date_time<boost::posix_time::ptime>("TimeStamp", "%Y-%m-%d %H:%M:%S.%f")
            << " " << left << setfill(' ') << setw(5) << facter::logging::log_level_attr
            << " " << facter::logging::namespace_attr
            << " - " << expr::smessage);

    sink->set_filter(facter::logging::log_level_attr >= facter::logging::warning);
    logging::add_common_attributes();

    // Before running tests, initialize Ruby
    auto ruby = api::instance();
    if (ruby) {
        ruby->initialize();
    }
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
