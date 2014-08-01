#include <facter/logging/logging.hpp>

#include <boost/log/support/date_time.hpp>
#include <boost/log/expressions/formatters/date_time.hpp>
#include <boost/log/utility/setup/console.hpp>
#include <boost/log/utility/setup/common_attributes.hpp>

using namespace std;
namespace expr = boost::log::expressions;

void facter::logging::configure_logging(facter::logging::log_level level)
{
    // Set filtering based on log_level (info, warning, debug, etc).
    auto sink = boost::log::add_console_log(std::cerr);

    sink->set_formatter(
        expr::stream
            << expr::format_date_time<boost::posix_time::ptime>("TimeStamp", "%Y-%m-%d %H:%M:%S.%f")
            << " " << left << setfill(' ') << setw(5) << facter::logging::log_level_attr
            << " " << facter::logging::namespace_attr
            << " - " << expr::smessage);

    sink->set_filter(facter::logging::log_level_attr >= level);
    boost::log::add_common_attributes();
}

