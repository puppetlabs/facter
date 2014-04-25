#ifndef FACTER_LOGGING_LOGGING_HPP_
#define FACTER_LOGGING_LOGGING_HPP_

// To use this header, you must:
// - Have log4cxx and Boost on the include path
// - Link in log4cxx
// - Configure log4cxx at runtime before any logging takes place
#include <log4cxx/logger.h>
#include <boost/format.hpp>

#define LOG_DECLARE_NAMESPACE(ns) static log4cxx::LoggerPtr g_logger = log4cxx::Logger::getLogger("puppetlabs.facter." ns);
#define LOG_MESSAGE(level, format, ...) \
    do { \
        facter::logging::log(g_logger, level, format, ##__VA_ARGS__); \
    } while (0)
#define LOG_DEBUG(format, ...) LOG_MESSAGE(facter::logging::log_level::debug, format, ##__VA_ARGS__)
#define LOG_INFO(format, ...) LOG_MESSAGE(facter::logging::log_level::info, format, ##__VA_ARGS__)
#define LOG_WARNING(format, ...) LOG_MESSAGE(facter::logging::log_level::warning, format, ##__VA_ARGS__)
#define LOG_ERROR(format, ...) LOG_MESSAGE(facter::logging::log_level::error, format, ##__VA_ARGS__)
#define LOG_FATAL(format, ...) LOG_MESSAGE(facter::logging::log_level::fatal, format, ##__VA_ARGS__)
#define LOG_IS_ENABLED(level) facter::logging::is_log_enabled(g_logger, level)
#define LOG_IS_DEBUG_ENABLED() LOG_IS_ENABLED(facter::logging::log_level::debug)
#define LOG_IS_INFO_ENABLED() LOG_IS_ENABLED(facter::logging::log_level::info)
#define LOG_IS_WARNING_ENABLED() LOG_IS_ENABLED(facter::logging::log_level::warning)
#define LOG_IS_ERROR_ENABLED() LOG_IS_ENABLED(facter::logging::log_level::error)
#define LOG_IS_FATAL_ENABLED() LOG_IS_ENABLED(facter::logging::log_level::fatal)

namespace facter { namespace logging {

    /**
     * Represents the supported logging levels.
     */
    enum class log_level
    {
        debug,
        info,
        warning,
        error,
        fatal
    };

    /**
     * Determines if the given log level is enabled for the given logger.
     * @param logger The logger to check.
     * @param level The logging level to check.
     * @return Returns true if the logging level is enabled or false if it is not.
     */
    bool is_log_enabled(log4cxx::LoggerPtr logger, log_level level);

    /**
     * Logs a given message to the given logger.
     * @param logger The logger to log the message to.
     * @param level The logging level to log with.
     * @param message The message to log.
     */
    void log(log4cxx::LoggerPtr logger, log_level level, std::string const& message);

    /**
     * Logs a given format message to the given logger.
     * @param logger The logger to log the message to.
     * @param level The logging level to log with.
     * @param message The message being formatted.
     */
    void log(log4cxx::LoggerPtr logger, log_level level, boost::format& message);

    /**
     * Logs a given format message to the given logger.
     * @tparam T The type of the first argument.
     * @tparam TArgs The types of the remaining arguments.
     * @param logger The logger to log to.
     * @param level The logging level to log with.
     * @param message The message being formatted.
     * @param arg The first argument to the message.
     * @param args The remaining arguments to the message.
     */
    template <typename T, typename... TArgs>
    void log(log4cxx::LoggerPtr logger, log_level level, boost::format& message, T arg, TArgs... args)
    {
        message % arg;
        log(logger, level, message, std::forward<TArgs>(args)...);
    }

    /**
     * Logs a given format message to the given logger.
     * @tparam TArgs The types of the arguments to format the message with.
     * @param logger The logger to log to.
     * @param level The logging level to log with.
     * @param format The message format.
     * @param args The remaining arguments to the message.
     */
    template <typename... TArgs>
    void log(log4cxx::LoggerPtr logger, log_level level, std::string const& format, TArgs... args)
    {
        boost::format message(format);
        log(logger, level, message, std::forward<TArgs>(args)...);
    }

}}  // namespace facter::logging

#endif  // FACTER_LOGGING_LOGGING_HPP_
