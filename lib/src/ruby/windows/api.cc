#include <facter/ruby/api.hpp>

using namespace std;

namespace facter { namespace ruby {

    string api::get_library_name(string const& version)
    {
        // TODO WINDOWS: Implement function.
        return "libruby.dll";
    }

}}  // namespace facter::ruby
