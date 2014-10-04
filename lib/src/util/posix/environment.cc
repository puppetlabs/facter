#include <facter/util/environment.hpp>
#include <boost/algorithm/string.hpp>
#include <cstdlib>
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

    bool environment::get(string const& name, string& value)
    {
        auto variable = getenv(name.c_str());
        if (!variable) {
            return false;
        }

        value = variable;
        return true;
    }

    bool environment::set(string const& name, string const& value)
    {
        return setenv(name.c_str(), value.c_str(), 1) == 0;
    }

    bool environment::clear(string const& name)
    {
        return unsetenv(name.c_str()) == 0;
    }

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

}}  // namespace facter::util
