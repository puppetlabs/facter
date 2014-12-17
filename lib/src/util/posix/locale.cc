// boost includes are not always warning-clean. Disable warnings that
// cause problems before including the headers, then re-enable the warnings.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wattributes"
#include <boost/filesystem/path.hpp>
#pragma GCC diagnostic pop

#include <locale>

namespace facter { namespace util {
    void set_locale(std::string const& id)
    {
        // Windows uses boost::locale to generate a UTF-8 compatible locale. Other platforms
        // assume UTF-8 should be used, so we can avoid the boost::locale dependency here.
        // GCC 4.8 doesn't yet implement the std::locale(std::string const&) interface, so use c-str.
        std::locale::global(std::locale(id.c_str()));

        // Setup boost::filesystem to use the locale. By default on Windows, it uses wchar_t with
        // the default system locale, resulting in 3- and 4-byte UTF characters being unsupported.
        // Using the boost::locale's system default fixes that by using a UTF-8 compatible locale.
        boost::filesystem::path::imbue(std::locale());
    }
}}  // namespace facter::util
