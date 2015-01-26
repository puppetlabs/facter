#include <facter/util/environment.hpp>
#include <facter/util/windows/windows.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/nowide/convert.hpp>
#include <functional>

using namespace std;

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

    void environment::each(function<bool(string&, string&)> callback)
    {
        // Enumerate all environment variables
        auto ptr = GetEnvironmentStringsW();
        for (auto variables = ptr; variables && *variables; variables += wcslen(variables) + 1) {
            string pair = boost::nowide::narrow(variables);
            string name;
            string value;

            auto pos = pair.find('=');
            if (pos == string::npos) {
                name = move(pair);
            } else {
                name = pair.substr(0, pos);
                value = pair.substr(pos + 1);
            }
            if (!callback(name, value)) {
                break;
            }
        }
        if (ptr) {
            FreeEnvironmentStringsW(ptr);
        }
    }

}}  // namespace facter::util
