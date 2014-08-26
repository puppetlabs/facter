#include <facter/logging/logging.hpp>

#include <boost/log/sources/severity_logger.hpp>
#include <boost/log/sources/record_ostream.hpp>
#include <boost/log/attributes/scoped_attribute.hpp>

using namespace std;
namespace src = boost::log::sources;
namespace attrs = boost::log::attributes;

namespace facter { namespace logging {

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

    void log(const string &logger, log_level level, string const& message)
    {
        src::severity_logger<log_level> slg;
        slg.add_attribute("Namespace", attrs::constant<std::string>(logger));

        static bool color = isatty(fileno(stderr));
        if (!color) {
            BOOST_LOG_SEV(slg, level) << message;
            return;
        }

        switch (level) {
            case log_level::trace:
                BOOST_LOG_SEV(slg, level) << cyan(message);
                break;
            case log_level::debug:
                BOOST_LOG_SEV(slg, level) << cyan(message);
                break;
            case log_level::info:
                BOOST_LOG_SEV(slg, level) << green(message);
                break;
            case log_level::warning:
                BOOST_LOG_SEV(slg, level) << yellow(message);
                break;
            case log_level::error:
                BOOST_LOG_SEV(slg, level) << red(message);
                break;
            case log_level::fatal:
                BOOST_LOG_SEV(slg, level) << red(message);
                break;
            default:
                BOOST_LOG_SEV(slg, level) << "Invalid logging level used.";
                break;
        }
    }

}}  // namespace facter::logging
