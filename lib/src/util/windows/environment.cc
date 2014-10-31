#include <facter/util/environment.hpp>
#include <boost/algorithm/string.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/windows/system_error.hpp>
#include <facter/util/windows/windows.hpp>
#include <cstdlib>

using namespace std;
using namespace facter::util::windows;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "util.windows.environment"

namespace facter { namespace util {

    struct search_path_helper
    {
        search_path_helper()
        {
            string paths;
            if (environment::get("PATH", paths)) {
                auto is_sep = bind(equal_to<char>(), placeholders::_1, environment::get_path_separator());
                boost::trim_if(paths, is_sep);
                boost::split(_paths, paths, is_sep, boost::token_compress_on);
            }
        }

        vector<string> const& search_paths() const
        {
            return _paths;
        }

     private:
         vector<string> _paths;
    };

    bool environment::get(string const& name, string& value)
    {
        // getenv on Windows won't get vars set by SetEnvironmentVariable in the same process.
        vector<char> buf(256);
        auto numChars = GetEnvironmentVariable(name.c_str(), buf.data(), buf.size());
        if (numChars > buf.size()) {
            buf.resize(numChars);
            numChars = GetEnvironmentVariable(name.c_str(), buf.data(), buf.size());
        }

        if (numChars == 0) {
            auto err = GetLastError();
            if (err != ERROR_ENVVAR_NOT_FOUND) {
                LOG_DEBUG("failure reading environment variable %1%: %2%", name, system_error(err));
            }
            return false;
        }

        value.assign(buf.data(), numChars);
        return true;
    }

    bool environment::set(string const& name, string const& value)
    {
        return SetEnvironmentVariable(name.c_str(), value.c_str()) != 0;
    }

    bool environment::clear(string const& name)
    {
        return SetEnvironmentVariable(name.c_str(), nullptr) != 0;
    }

    char environment::get_path_separator()
    {
        return ';';
    }

    static search_path_helper helper;

    vector<string> const& environment::search_paths()
    {
        return helper.search_paths();
    }

    void environment::reload_search_paths()
    {
        helper = search_path_helper();
    }

}}  // namespace facter::util
