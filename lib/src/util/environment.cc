#include <facter/util/environment.hpp>
#include <leatherman/util/environment.hpp>
#include <boost/nowide/cenv.hpp>

using namespace std;

namespace facter { namespace util {

    bool environment::get(string const& name, string& value)
    {
        return leatherman::util::environment::get(name, value);
    }

    bool environment::set(string const& name, string const& value)
    {
        return leatherman::util::environment::set(name, value);
    }

    bool environment::clear(string const& name)
    {
        return leatherman::util::environment::clear(name);
    }

    vector<string> const& environment::search_paths()
    {
        return leatherman::util::environment::search_paths();
    }

    void environment::reload_search_paths()
    {
        leatherman::util::environment::reload_search_paths();
    }

    void environment::each(function<bool(string&, string&)> callback)
    {
        leatherman::util::environment::each(callback);
    }

}}  // namespace facter::util
