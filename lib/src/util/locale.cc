// boost includes are not always warning-clean. Disable warnings that
// cause problems before including the headers, then re-enable the warnings.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wattributes"
#include <boost/filesystem/path.hpp>
#include <boost/locale.hpp>
#pragma GCC diagnostic pop

namespace facter { namespace util {
    void set_locale(std::string const& id)
    {
        // Setup locales; this must be done on startup for any use of libfacter.
        // The system default locale is set with id == "", except on Windows boost::locale's
        // generator uses a compatible UTF-8 equivalent. This results in UTF-8 being the default
        // on all platforms.
        std::locale::global(boost::locale::generator().generate(id));

        // Setup boost::filesystem to use the locale. By default on Windows, it uses wchar_t with
        // the default system locale, resulting in 3- and 4-byte UTF characters being unsupported.
        // Using the boost::locale's system default fixes that by using a UTF-8 compatible locale.
        boost::filesystem::path::imbue(std::locale());
    }
}}  // namespace facter::util
