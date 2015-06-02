#include <facter/util/environment.hpp>
#include <boost/algorithm/string.hpp>
#include <functional>
#include <unistd.h>

using namespace std;

// Some platforms need environ explicitly declared
extern char** environ;

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
            // Ruby Facter expects /sbin and /usr/sbin to be searched for programs
            _paths.push_back("/sbin");
            _paths.push_back("/usr/sbin");
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
        return ':';
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
        for (char const* const* variable = environ; *variable; ++variable) {
            string pair = *variable;
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
    }

}}  // namespace facter::util
