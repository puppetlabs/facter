#include <facter/ruby/api.hpp>

using namespace std;

namespace facter { namespace ruby {

    dynamic_library api::find_library()
    {
        // WINDOWS TODO: implement this function
        // It should go something like this:
        // 1. Use dynamic_library::find_by_name (change it to support regex pattern and use CreateToolhelp32Snapshot to implement)
        // 2. If not found, search the path for ruby.exe
        // 3. If ruby.exe found, look in ..\lib for the highest version ruby.
        return dynamic_library();
    }

}}  // namespace facter::ruby
