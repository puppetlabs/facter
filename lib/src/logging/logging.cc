#include <logging/logging.hpp>

using namespace std;
using namespace log4cxx;
using boost::format;

namespace cfacter { namespace logging {

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

    void log(LoggerPtr logger, log_level level, string const& message)
    {
        if (level == log_level::debug) {
            LOG4CXX_DEBUG(logger, message);
        } else if (level == log_level::info) {
            LOG4CXX_INFO(logger, message);
        } else if (level == log_level::warning) {
            LOG4CXX_WARN(logger, message);
        } else if (level == log_level::error) {
            LOG4CXX_ERROR(logger, message);
        } else if (level == log_level::fatal) {
            LOG4CXX_FATAL(logger, message);
        } else {
            LOG4CXX_DEBUG(logger, "Invalid logging level used.");
        }
    }

    void log(LoggerPtr logger, log_level level, format& message)
    {
        log(logger, level, message.str());
    }

}}  // namespace cfacter::logging