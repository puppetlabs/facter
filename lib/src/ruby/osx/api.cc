#include <facter/ruby/api.hpp>

using namespace std;

namespace facter { namespace ruby {

    string api::get_library_name(string const& version)
    {
        if (version.empty()) {
            return "libruby.dylib";
        }
        return "libruby." + version + ".dylib";
    }

}}  // namespace facter::ruby
