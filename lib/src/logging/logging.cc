#include <facter/logging/logging.hpp>
#include <leatherman/util/environment.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>
#include <boost/filesystem.hpp>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;
using namespace leatherman::util;
namespace lm = leatherman::logging;

#ifdef LEATHERMAN_USE_LOCALES
static void setup_logging_internal(ostream& os, bool use_locale)
{
    // Initialize boost filesystem's locale to a UTF-8 default.
    // Logging gets setup the same way via the default 2nd argument.
    if (use_locale) {
        boost::filesystem::path::imbue(leatherman::locale::get_locale());
    }
    lm::setup_logging(os, "", PROJECT_NAME, use_locale);
}
#else
static void setup_logging_internal(ostream& os, bool)
{
    lm::setup_logging(os, "", PROJECT_NAME, false);
}
#endif

static const char* lc_vars[] = {
    "LC_CTYPE",
    "LC_NUMERIC",
    "LC_TIME",
    "LC_COLLATE",
    "LC_MONETARY",
    "LC_MESSAGES",
    "LC_PAPER",
    "LC_ADDRESS",
    "LC_TELEPHONE",
    "LC_MEASUREMENT",
    "LC_IDENTIFICATION",
    "LC_ALL"
};

namespace facter { namespace logging {
    istream& operator>>(istream& in, level& lvl)
    {
        lm::log_level lm_level;
        in >> lm_level;
        lvl = static_cast<level>(lm_level);
        return in;
    }

    ostream& operator<<(ostream& os, level lvl)
    {
        os << static_cast<lm::log_level>(lvl);
        return os;
    }

    void setup_logging(ostream& os)
    {
        try {
            setup_logging_internal(os, true);
        } catch (exception const&) {
            for (auto var : lc_vars) {
                environment::clear(var);
            }
            environment::set("LANG", "C");
            environment::set("LC_ALL", "C");
            try {
                setup_logging_internal(os, true);
                // We can't log the issue until after logging is setup. Rely on the exception for any other
                // error reporting.
                log(level::warning, "locale environment variables were bad; continuing with LANG=C LC_ALL=C");
            } catch (exception const& e) {
                // If we fail again even with a clean environment, we
                // need to signal to our consumer that things went
                // sideways.
                //
                // Since logging is busted, we raise an exception that
                // signals to the consumer that a special action must
                // be taken to alert the user.
                try {
                    setup_logging_internal(os, false);
                    log(level::warning, "Could not initialize locale, even with LC_* variables cleared. Continuing without localization support");
                } catch (exception const& e) {
                    throw locale_error(_("could not initialize logging, even with locale variables reset to LANG=C LC_ALL=C: {1}", e.what()));
                }
            }
        }
    }

    void set_level(level lvl)
    {
        lm::set_level(static_cast<lm::log_level>(lvl));
    }

    level get_level()
    {
        return static_cast<level>(lm::get_level());
    }

    void set_colorization(bool color)
    {
        lm::set_colorization(color);
    }

    bool get_colorization()
    {
        return lm::get_colorization();
    }

    bool is_enabled(level lvl)
    {
        return lm::is_enabled(static_cast<lm::log_level>(lvl));
    }

    bool error_logged()
    {
        return lm::error_has_been_logged();
    }

    void clear_logged_errors()
    {
        lm::clear_error_logged_flag();
    }

    std::string translate(std::string const& msg)
    {
#ifdef LEATHERMAN_I18N
        return leatherman::locale::translate(msg);
#else
        // When locales are disabled, use boost::format, which expects %N% style formatting
        static const boost::regex match{"\\{(\\d+)\\}"};
        static const std::string repl{"%\\1%"};
        return boost::regex_replace(leatherman::locale::translate(msg), match, repl);
#endif
    }

    void log(level lvl, string const& message)
    {
        lm::log(LOG_NAMESPACE, static_cast<lm::log_level>(lvl), 0, translate(message));
    }

    void colorize(ostream &os, level lvl)
    {
        lm::colorize(os, static_cast<lm::log_level>(lvl));
    }

}}  // namespace facter::logging
