#include <facter/logging/logging.hpp>

using namespace std;

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

    string colorize(string const& message, log_level level, FILE *log)
    {
        static bool color = isatty(fileno(log));
        if (!color) {
            return message;
        }

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

}}  // namespace facter::logging

