#include <facter/util/environment.hpp>
#include <boost/nowide/cenv.hpp>

using namespace std;

namespace facter { namespace util {

    bool environment::get(string const& name, string& value)
    {
        auto variable = boost::nowide::getenv(name.c_str());
        if (!variable) {
            return false;
        }

        value = variable;
        return true;
    }

    bool environment::set(string const& name, string const& value)
    {
        return boost::nowide::setenv(name.c_str(), value.c_str(), 1) == 0;
    }

    bool environment::clear(string const& name)
    {
        return boost::nowide::unsetenv(name.c_str()) == 0;
    }

}}  // namespace facter::util
