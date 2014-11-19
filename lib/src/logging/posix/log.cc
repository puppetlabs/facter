#include <facter/logging/logging.hpp>

#include <boost/log/sources/severity_logger.hpp>
#include <boost/log/sources/record_ostream.hpp>
#include <boost/log/attributes/scoped_attribute.hpp>

using namespace std;
namespace src = boost::log::sources;
namespace attrs = boost::log::attributes;

namespace facter { namespace logging {

    string const& colorize(log_level level)
    {
        static const string none = "";
        static const string cyan = "\33[0;36m";
        static const string green = "\33[0;32m";
        static const string yellow = "\33[0;33m";
        static const string red = "\33[0;31m";

        if (level == log_level::trace || level == log_level::debug) {
            return cyan;
        } else if (level == log_level::info) {
            return green;
        } else if (level == log_level::warning) {
            return yellow;
        } else if (level == log_level::error || level == log_level::fatal) {
            return red;
        }
        return none;
    }

    string const& colorize()
    {
        static const string reset = "\33[0m";
        return reset;
    }

    void log(const string &logger, log_level level, string const& message)
    {
        src::severity_logger<log_level> slg;
        slg.add_attribute("Namespace", attrs::constant<std::string>(logger));

        static bool color = isatty(fileno(stderr));
        if (!color) {
            BOOST_LOG_SEV(slg, level) << message;
        } else {
            BOOST_LOG_SEV(slg, level) << colorize(level) << message << colorize();
        }
    }

}}  // namespace facter::logging
