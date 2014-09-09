#include <facter/ruby/api.hpp>

using namespace facter::util;

namespace facter { namespace ruby {

    dynamic_library api::find_library()
    {
        // WINDOWS TODO: implement this function
        // It should go something like this:
        // 1. Use dynamic_library::find_by_name (change it to support regex pattern and use CreateToolhelp32Snapshot to implement)
        // 2. Check the FACTER_RUBY environment variable
        // 3. Search the path for ruby.exe and then look in ..\lib for a ruby library to use.
        return dynamic_library();
    }

}}  // namespace facter::ruby
