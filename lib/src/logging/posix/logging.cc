#include <facter/logging/logging.hpp>
#include <vector>
#include <unistd.h>
#include <cstdio>

#include <boost/log/sources/severity_logger.hpp>
#include <boost/log/sources/record_ostream.hpp>
#include <boost/log/attributes/scoped_attribute.hpp>

using namespace std;
using boost::format;
namespace src = boost::log::sources;
namespace attrs = boost::log::attributes;
namespace keywords = boost::log::keywords;

namespace facter { namespace logging {

    bool is_log_enabled(const std::string &logger, log_level level) {
        // If the severity_logger returns a record for the specified
        // level, logging is enabled. Otherwise it isn't.
        // This could be expensive, so another pattern might
        // make more sense.
        src::severity_logger<log_level> slg;
        return (slg.open_record(keywords::severity = level) ? true : false);
    }

    static string cyan(string const& message) {
        return "\33[0;36m" + message + "\33[0m";
    }

    static string green(string const& message) {
        return "\33[0;32m" + message + "\33[0m";
    }

    static string yellow(string const& message) {
        return "\33[0;33m" + message + "\33[0m";
    }

    static string red(string const& message) {
        return "\33[0;31m" + message + "\33[0m";
    }

    static string colorize(string const& message, log_level level)
    {
        switch (level) {
            case log_level::trace:
                return cyan(message);
            case log_level::debug:
                return cyan(message);
            case log_level::info:
                return green(message);
            case log_level::warning:
                return yellow(message);
            case log_level::error:
                return red(message);
            case log_level::fatal:
                return red(message);
            default:
                return "Invalid logging level used.";
        }
    }

    std::ostream& operator<<(std::ostream& strm, log_level level)
    {
        std::vector<std::string> strings = {"TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"};
        if (static_cast<size_t>(level) < strings.size()) {
            strm << strings[static_cast<size_t>(level)];
        } else {
            strm << static_cast<int>(level);
        }
        return strm;
    }

    void log(const string &logger, log_level level, string const& message)
    {
        static bool color = isatty(fileno(stdout));

        src::severity_logger<log_level> slg;
        slg.add_attribute("Namespace", attrs::constant<std::string>(logger));
        BOOST_LOG_SEV(slg, level) << (color ? colorize(message, level) : message);
    }

    void log(const string &logger, log_level level, format& message)
    {
        log(logger, level, message.str());
    }

}}  // namespace facter::logging
