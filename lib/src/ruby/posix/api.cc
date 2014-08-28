#include <facter/ruby/api.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/regex.hpp>
#include <facter/util/environment.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::execution;
using namespace boost::filesystem;

namespace facter { namespace ruby {

    dynamic_library api::find_library()
    {
#if __APPLE__ && __MACH__
        re_adapter regex("libruby(?:[-.](\\d+))?(?:\\.(\\d+))?(?:\\.(\\d+))?\\.dylib$");
#else
        // Matches either libruby.so<version> or libruby-*.so<version>
        re_adapter regex("libruby(?:-.*)?\\.so(?:\\.(\\d+))?(?:\\.(\\d+))?(?:\\.(\\d+))?$");
#endif

        // First search for an already loaded Ruby
        dynamic_library library = dynamic_library::find_by_symbol("ruby_init");
        if (library.loaded()) {
            return library;
        }

        // Next try an environment variable
        // This allows users to directly specify the ruby version to use
        string value;
        if (environment::get("FACTER_RUBY", value)) {
            if (library.load(value)) {
                return library;
            }
        }

        // Next search for where ruby is installed
        string ruby = execution::which("ruby");
        if (!ruby.empty()) {
            boost::system::error_code ec;
            path libdir = canonical(path(ruby).remove_filename() / ".." / "lib", ec);
            if (!ec) {
                // Search the library directory for the "latest" libruby
                string major;
                string minor;
                string patch;
                string libruby;
                directory::each_file(libdir.string(), [&](string const& file) {
                    string current_major;
                    string current_minor;
                    string current_patch;
                    if (!re_search(file, regex, &current_major, &current_minor, &current_patch)) {
                        return true;
                    }

                    if ((current_major > major) ||
                        (current_major == major && current_minor > minor) ||
                        (current_major == major && current_minor == minor && current_patch >= patch)) {
                        major = current_major;
                        minor = current_minor;
                        patch = current_patch;
                        libruby = file;
                    }
                    return true;
                }, "libruby");

                if (!libruby.empty() && library.load(libruby)) {
                    return library;
                }
            }
        }

        return library;
    }

}}  // namespace facter::ruby
