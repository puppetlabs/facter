/**
 * @file
 * Declares the logging functions and macros.
 */
#pragma once

// To use this header, you must:
// - Have Boost on the include path
// - Link in Boost.Log
// - Configure Boost.Log at runtime before any logging takes place
/**
 * See Boost.Log's documentation.
 */
#include <boost/log/core.hpp>
#include <boost/log/expressions.hpp>
#include <boost/format.hpp>
#include <cstdio>
#include <functional>

/**
 * Defines the logging namespace.
 */
#define LOG_NAMESPACE "puppetlabs.facter"

/**
 * Logs a message.
 * @param level The logging level for the message.
 * @param format The format message.
 * @param ... The format message parameters.
 */
#define LOG_MESSAGE(level, format, ...) \
    if (facter::logging::is_enabled(level)) { \
        facter::logging::log(LOG_NAMESPACE, level, format, ##__VA_ARGS__); \
    }
/**
 * Logs a trace message.
 * @param format The format message.
 * @param ... The format message parameters.
 */
#define LOG_TRACE(format, ...) LOG_MESSAGE(facter::logging::log_level::trace, format, ##__VA_ARGS__)
/**
 * Logs a debug message.
 * @param format The format message.
 * @param ... The format message parameters.
 */
#define LOG_DEBUG(format, ...) LOG_MESSAGE(facter::logging::log_level::debug, format, ##__VA_ARGS__)
/**
 * Logs an info message.
 * @param format The format message.
 * @param ... The format message parameters.
 */
#define LOG_INFO(format, ...) LOG_MESSAGE(facter::logging::log_level::info, format, ##__VA_ARGS__)
/**
 * Logs a warning message.
 * @param format The format message.
 * @param ... The format message parameters.
 */
#define LOG_WARNING(format, ...) LOG_MESSAGE(facter::logging::log_level::warning, format, ##__VA_ARGS__)
/**
 * Logs an error message.
 * @param format The format message.
 * @param ... The format message parameters.
 */
#define LOG_ERROR(format, ...) LOG_MESSAGE(facter::logging::log_level::error, format, ##__VA_ARGS__)
/**
 * Logs a fatal message.
 * @param format The format message.
 * @param ... The format message parameters.
 */
#define LOG_FATAL(format, ...) LOG_MESSAGE(facter::logging::log_level::fatal, format, ##__VA_ARGS__)
/**
 * Determines if the trace logging level is enabled.
 * @returns Returns true if trace logging is enabled or false if it is not enabled.
 */
#define LOG_IS_TRACE_ENABLED() facter::logging::is_enabled(facter::logging::log_level::trace)
/**
 * Determines if the debug logging level is enabled.
 * @returns Returns true if debug logging is enabled or false if it is not enabled.
 */
#define LOG_IS_DEBUG_ENABLED() facter::logging::is_enabled(facter::logging::log_level::debug)
/**
 * Determines if the info logging level is enabled.
 * @returns Returns true if info logging is enabled or false if it is not enabled.
 */
#define LOG_IS_INFO_ENABLED() facter::logging::is_enabled(facter::logging::log_level::info)
/**
 * Determines if the warning logging level is enabled.
 * @returns Returns true if warning logging is enabled or false if it is not enabled.
 */
#define LOG_IS_WARNING_ENABLED() facter::logging::is_enabled(facter::logging::log_level::warning)
/**
 * Determines if the error logging level is enabled.
 * @returns Returns true if error logging is enabled or false if it is not enabled.
 */
#define LOG_IS_ERROR_ENABLED() facter::logging::is_enabled(facter::logging::log_level::error)
/**
 * Determines if the fatal logging level is enabled.
 * @returns Returns true if fatal logging is enabled or false if it is not enabled.
 */
#define LOG_IS_FATAL_ENABLED() facter::logging::is_enabled(facter::logging::log_level::fatal)

namespace facter { namespace logging {

    /**
     * Represents the supported logging levels.
     */
    enum class log_level
    {
        none,
        trace,
        debug,
        info,
        warning,
        error,
        fatal
    };

    /**
     * The Boost.Log attribute for log level (severity).
     * The BOOST_LOG_SEV macro implicitly adds a source-specific attribute
     * "Severity" of the template type on construction, so the attribute
     * name "Severity" of log_level_attr is tied to BOOST_LOG_SEV.
     */
    BOOST_LOG_ATTRIBUTE_KEYWORD(log_level_attr, "Severity", log_level);
    /**
     * The Boost.Log attribute for namespace.
     */
    BOOST_LOG_ATTRIBUTE_KEYWORD(namespace_attr, "Namespace", std::string);

    /**
     * Reads a log level from an input stream.
     * This is used in boost::lexical_cast<log_level>.
     * @param in The input stream.
     * @param level The returned log level.
     * @returns Returns the input stream.
     */
    std::istream& operator>>(std::istream& in, log_level& level);

    /**
     * Produces the printed representation of logging level.
     * @param strm The stream to write.
     * @param level The logging level to print.
     * @return Returns the stream after writing to it.
     */
    std::ostream& operator<<(std::ostream& strm, log_level level);

    /**
     * Sets up logging for the given stream.
     * The logging level is set to warning by default.
     * @param dst Destination stream for logging output.
     */
    void setup_logging(std::ostream &dst);

    /**
     * Sets the current log level.
     * @param level The new current log level to set.
     */
    void set_level(log_level level);

    /**
     * Gets the current log level.
     * @return Returns the current log level.
     */
    log_level get_level();

    /**
     * Sets whether or not log output is colorized.
     * @param color Pass true if log output is colorized or false if it is not colorized.
     */
    void set_colorization(bool color);

    /**
     * Gets whether or not the log output is colorized.
     * @return Returns true if log output is colorized or false if it is not colorized.
     */
    bool get_colorization();

    /**
     * Provides a callback for when a message is logged.
     * If the callback returns false, the message will not be logged.
     * @param callback The callback to call when a message is about to be logged.
     */
    void on_message(std::function<bool(log_level, std::string const&)> callback);

    /**
     * Determines if the given log level is enabled for the given logger.
     * @param level The logging level to check.
     * @return Returns true if the logging level is enabled or false if it is not.
     */
    bool is_enabled(log_level level);

    /**
     * Determine if an error has been logged
     * @return Returns true if an error or critical message has been logged
     */
    bool error_has_been_logged();

    /**
     * Clear the flag that indicates an error has been logged.
     * This is necessary for testing the flagging functionality. This function should
     * not be used by library consumers.
     */
    void clear_error_logged_flag();

    /**
     * Logs a given message to the given logger.
     * @param logger The logger to log the message to.
     * @param level The logging level to log with.
     * @param message The message to log.
     */
    void log(const std::string &logger, log_level level, std::string const& message);

    /**
     * Logs a given format message to the given logger.
     * @param logger The logger to log the message to.
     * @param level The logging level to log with.
     * @param message The message being formatted.
     */
    void log(const std::string &logger, log_level level, boost::format& message);

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
    void log(const std::string &logger, log_level level, boost::format& message, T arg, TArgs... args)
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
    void log(const std::string &logger, log_level level, std::string const& format, TArgs... args)
    {
        boost::format message(format);
        log(logger, level, message, std::forward<TArgs>(args)...);
    }

    /**
     * Starts colorizing for the given log level.
     * This is a no-op on platforms that don't natively support terminal colors.
     * @param level The log level to colorize for.
     * @return Returns the start code for colorization or an empty string if not supported.
     */
    const std::string& colorize(log_level level);

    /**
     * Resets the colorization.
     * This is a no-op on platforms that don't natively support terminal colors.
     * @return Returns the reset code for colorization or an empty string if not supported.
     */
    const std::string& colorize();

}}  // namespace facter::logging
