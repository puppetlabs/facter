#include <internal/ruby/api.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace ruby {

    dynamic_library api::find_loaded_library()
    {
        const string libruby_pattern = ".*ruby(\\d)?(\\d)?(\\d)?\\.dll";
        return dynamic_library::find_by_pattern(libruby_pattern);
    }

    string api::libruby_configdir()
    {
        return "bindir";
    }

}}  // namespace facter::ruby
