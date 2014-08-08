#include <gmock/gmock.h>
#include <facter/logging/logging.hpp>

#include <boost/log/support/date_time.hpp>
#include <boost/log/expressions/formatters/date_time.hpp>
#include <boost/log/utility/setup/console.hpp>
#include <boost/log/utility/setup/common_attributes.hpp>
namespace expr = boost::log::expressions;
namespace logging = boost::log;

using namespace std;

struct Environment : testing::Environment
{
    virtual void SetUp()
    {
        // Setup Boost.Log
        auto sink = logging::add_console_log();

        sink->set_formatter(
            expr::stream
                << expr::format_date_time<boost::posix_time::ptime>("TimeStamp", "%Y-%m-%d %H:%M:%S.%f")
                << " " << left << setfill(' ') << setw(5) << facter::logging::log_level_attr
                << " " << facter::logging::namespace_attr
                << " - " << expr::smessage);

        sink->set_filter(facter::logging::log_level_attr >= facter::logging::warning);
        logging::add_common_attributes();
    }

    virtual void TearDown()
    {
    }
};

static ::testing::Environment* const env = ::testing::AddGlobalTestEnvironment(new Environment());
