#include <facter/util/dynamic_library.hpp>
#include <boost/format.hpp>

using namespace std;

namespace facter { namespace util {

    dynamic_library dynamic_library::find_by_name(std::string const& name)
    {
        // TODO WINDOWS: Implement function.
        return dynamic_library();
    }

    dynamic_library dynamic_library::find_by_symbol(std::string const& symbol)
    {
        // TODO WINDOWS: Implement function.
        return dynamic_library();
    }

    bool dynamic_library::load(string const& name)
    {
        // TODO WINDOWS: Implement function.
        return false;
    }

    void dynamic_library::close()
    {
        // TODO WINDOWS: Implement function.
    }

    void* dynamic_library::find_symbol(string const& name, bool throw_if_missing, string const& alias) const
    {
        // TODO WINDOWS: Implement function.
        return nullptr;
    }

}}  // namespace facter::util
