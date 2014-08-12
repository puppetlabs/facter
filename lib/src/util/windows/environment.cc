#include <facter/util/environment.hpp>
#include <facter/util/string.hpp>
#include <cstdlib>

using namespace std;

namespace facter { namespace util {

    struct search_path_helper
    {
        search_path_helper()
        {
            string paths;
            if (environment::get("PATH", paths)) {
                _paths = split(paths, environment::get_path_separator());
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
        auto variable = getenv(name.c_str());
        if (!variable) {
            return false;
        }

        value = variable;
        return true;
    }

    void environment::set(string const& name, string const& value)
    {
        // TODO WINDOWS: Implement function.
    }

    char environment::get_path_separator()
    {
        return ';';
    }

    vector<string> const& environment::search_paths()
    {
        static search_path_helper helper;
        return helper.search_paths();
    }

}}  // namespace facter::util
