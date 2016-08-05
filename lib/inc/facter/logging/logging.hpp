/**
* @file
* Declares the Facter logging functions.
*/
#pragma once

#include <stdexcept>
#include <ostream>
#include <string>
#include <boost/format.hpp>
#include "../export.h"

namespace facter { namespace logging {

    /**
     * Represents the supported logging levels.
     */
    enum class level
    {
        /**
         * No logging level.
         */
        none,
        /**
         * Trace level.
         */
        trace,
        /**
         * Debug level.
         */
        debug,
        /**
         * Info level.
         */
        info,
        /**
         * Warning level.
         */
        warning,
        /**
         * Error level.
         */
        error,
        /**
         * Fatal error level.
         */
        fatal
    };

    /**
     * Reads a logging level from an input stream.
     * This is used in boost::lexical_cast<level>.
     * @param in The input stream.
     * @param lvl The returned logging level.
     * @returns Returns the input stream.
     */
    LIBFACTER_EXPORT std::istream& operator>>(std::istream& in, level& lvl);

    /**
     * Produces the printed representation of a logging level.
     * @param os The stream to write.
     * @param lvl The logging level to write.
     * @return Returns the stream after writing to it.
     */
    LIBFACTER_EXPORT std::ostream& operator<<(std::ostream& os, level lvl);

    /**
     * Sets up logging for the given stream.
     * The logging level is set to warning by default.
     * @param os The output stream to configure for logging.
     */
    LIBFACTER_EXPORT void setup_logging(std::ostream& os);

    /**
     * Sets the current logging level.
     * @param lvl The new current logging level to set.
     */
    LIBFACTER_EXPORT void set_level(level lvl);

    /**
     * Gets the current logging level.
     * @return Returns the current logging level.
     */
    LIBFACTER_EXPORT level get_level();

    /**
     * Sets whether or not log output is colorized.
     * @param color Pass true if log output is colorized or false if it is not colorized.
     */
    LIBFACTER_EXPORT void set_colorization(bool color);

    /**
     * Gets whether or not the log output is colorized.
     * @return Returns true if log output is colorized or false if it is not colorized.
     */
    LIBFACTER_EXPORT bool get_colorization();

    /**
     * Determines if the given logging level is enabled.
     * @param lvl The logging level to check.
     * @return Returns true if the logging level is enabled or false if it is not.
     */
    LIBFACTER_EXPORT bool is_enabled(level lvl);

    /**
     * Determine if an error has been logged.
     * @return Returns true if an error or critical message has been logged.
     */
    LIBFACTER_EXPORT bool error_logged();

    /**
     * Clears logged errors.
     */
    LIBFACTER_EXPORT void clear_logged_errors();

    /**
     * Translate text using the locale initialized by this library.
     * @param msg The string to translate.
     * @return The translated string.
     */
    LIBFACTER_EXPORT std::string translate(std::string const& msg);

    /**
     * Format a text message.
     * @tparam TArgs The format argument types.
     * @param fmt The format string.
     * @param args The format arguments.
     * @return The formatted string.
     */
    template <typename... TArgs>
    std::string format(std::string const& fmt, TArgs... args)
    {
        boost::format msg{translate(fmt)};
        (void) std::initializer_list<int>{ ((void)(msg % args), 0)... };
        return msg.str();
    }

    /**
     * Format a text message.
     * Alias for format(...); Convenience function for adding i18n support.
     * @tparam TArgs The format argument types.
     * @param fmt The format string.
     * @param args The format arguments.
     * @return The formatted string.
     */
    template<typename... TArgs>
    inline std::string _(std::string const& fmt, TArgs&&... args)
    {
        return format(std::forward<decltype(fmt)>(fmt), std::forward<TArgs>(args)...);
    }

    /**
     * Log a message.
     * @param lvl The logging level to log with.
     * @param msg The message to log.
     */
    LIBFACTER_EXPORT void log(level lvl, std::string const& msg);

    /**
     * Log a formatted message.
     * @tparam TArgs The format argument types.
     * @param lvl The logging level to log with.
     * @param fmt The format string.
     * @param args The format arguments.
     */
    template <typename... TArgs>
    inline void log(level lvl, std::string const& fmt, TArgs... args)
    {
        log(std::forward<decltype(lvl)>(lvl), format(fmt, std::forward<TArgs>(args)...));
    }

    /**
     * Starts colorizing for the given logging level.
     * This is a no-op on platforms that don't natively support terminal colors.
     * @param os The stream to colorize.
     * @param lvl The logging level to colorize for. Defaults to none, which resets colorization.
     */
    LIBFACTER_EXPORT void colorize(std::ostream &os, level lvl = level::none);

    /**
     * Exception to indicate that locale setup was not possible.
     */
    class locale_error : public std::runtime_error {
    public:
         /**
          * Constructs a locale_error exception.
          * @param msg The exception message.
          */
         explicit locale_error(const std::string& msg) : std::runtime_error(msg) {}
    };

}}  // namespace facter::logging
