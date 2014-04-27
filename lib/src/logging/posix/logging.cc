#include <facter/logging/logging.hpp>
#include <unistd.h>
#include <cstdio>

using namespace std;
using namespace log4cxx;
using boost::format;

namespace facter { namespace logging {

    bool is_log_enabled(LoggerPtr logger, log_level level) {
        if (level == log_level::debug) {
            return logger->isDebugEnabled();
        } else if (level == log_level::info) {
            return logger->isInfoEnabled();
        } else if (level == log_level::warning) {
            return logger->isWarnEnabled();
        } else if (level == log_level::error) {
            return logger->isErrorEnabled();
        } else if (level == log_level::fatal) {
            return logger->isFatalEnabled();
        }
        return false;
    }

    string cyan(string const& message) {
        return "\33[0;36m" + message + "\33[0m";
    }

    string green(string const& message) {
        return "\33[0;32m" + message + "\33[0m";
    }

    string yellow(string const& message) {
        return "\33[0;33m" + message + "\33[0m";
    }

    string red(string const& message) {
        return "\33[0;31m" + message + "\33[0m";
    }

    void log(LoggerPtr logger, log_level level, string const& message)
    {
        static bool color = isatty(fileno(stdout));

        if (level == log_level::debug) {
            LOG4CXX_DEBUG(logger, (color ? cyan(message) : message));
        } else if (level == log_level::info) {
            LOG4CXX_INFO(logger, (color ? green(message) : message));
        } else if (level == log_level::warning) {
            LOG4CXX_WARN(logger, (color ? yellow(message) : message));
        } else if (level == log_level::error) {
            LOG4CXX_ERROR(logger, (color ? red(message) : message));
        } else if (level == log_level::fatal) {
            LOG4CXX_FATAL(logger, (color ? red(message) : message));
        } else {
            LOG4CXX_DEBUG(logger, "Invalid logging level used.");
        }
    }

    void log(LoggerPtr logger, log_level level, format& message)
    {
        log(logger, level, message.str());
    }

}}  // namespace facter::logging
