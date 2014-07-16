#include <facter/util/environment.hpp>
#include <cstdlib>

using namespace std;

namespace facter { namespace util {

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
        setenv(name.c_str(), value.c_str(), 1);
    }

    char environment::get_path_separator()
    {
        return ':';
    }

}}  // namespace facter::util
