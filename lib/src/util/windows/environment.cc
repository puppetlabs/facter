#include <facter/util/environment.hpp>
#include <boost/algorithm/string.hpp>
#include <facter/logging/logging.hpp>
#include <cstdlib>
#include <windows.h>

using namespace std;

LOG_DECLARE_NAMESPACE("util.windows.environment")

namespace facter { namespace util {

    struct search_path_helper
    {
        search_path_helper()
        {
            string paths;
            if (environment::get("PATH", paths)) {
                boost::split(_paths, paths, bind(equal_to<char>(), placeholders::_1, environment::get_path_separator()), boost::token_compress_on);
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

    vector<string> const& environment::search_paths()
    {
        static search_path_helper helper;
        return helper.search_paths();
    }

}}  // namespace facter::util
