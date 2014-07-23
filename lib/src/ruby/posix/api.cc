#include <facter/ruby/api.hpp>

using namespace std;

namespace facter { namespace ruby {

    string api::get_library_name(string const& version)
    {
        char const* basename = "libruby.so";

        if (version.empty()) {
            return basename;
        }
        return string(basename) + "." + version;
    }

}}  // namespace facter::ruby
