#include <internal/ruby/api.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace ruby {

    dynamic_library api::find_loaded_library()
    {
        return dynamic_library::find_by_symbol("ruby_init");
    }

}}  // namespace facter::ruby
