#include <facter/logging/logging.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>
#include <boost/filesystem.hpp>

using namespace std;
namespace lm = leatherman::logging;

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
        // Initialize boost filesystem's locale to a UTF-8 default.
        // Logging gets setup the same way via the default 2nd argument.
#if !defined(__sun) || !defined(__GNUC__)
        // Locale support in GCC on Solaris is busted, so skip it.
        boost::filesystem::path::imbue(leatherman::locale::get_locale());
#endif
        lm::setup_logging(os);
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

    void log(level lvl, string const& message)
    {
        lm::log(LOG_NAMESPACE, static_cast<lm::log_level>(lvl), 0, message);
    }

    void log(level lvl, boost::format& message)
    {
        log(lvl, message.str());
    }

    void colorize(ostream &os, level lvl)
    {
        lm::colorize(os, static_cast<lm::log_level>(lvl));
    }

}}  // namespace facter::logging
