#include <facter/ruby/api.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/regex.hpp>
#include <facter/util/environment.hpp>
#include <facter/logging/logging.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::execution;
using namespace boost::filesystem;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "ruby"

namespace facter { namespace ruby {

    dynamic_library api::find_library()
    {
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
            } else {
                LOG_WARNING("ruby library %1% could not be loaded.", value);
            }
        }

        // Next search for where ruby is installed
        string ruby = execution::which("ruby");
        if (!ruby.empty()) {
            boost::system::error_code ec;
            path libdir = canonical(path(ruby).remove_filename() / ".." / "lib", ec);
            if (!ec) {
                LOG_DEBUG("searching %1% for ruby libraries.", libdir);

                // Search the library directory for the "latest" libruby
#if __APPLE__ && __MACH__
                re_adapter regex("libruby(?:[-.](\\d+))?(?:\\.(\\d+))?(?:\\.(\\d+))?\\.dylib$");
#else
                // Matches either libruby.so<version> or libruby-*.so<version>
                re_adapter regex("libruby(?:-.*)?\\.so(?:\\.(\\d+))?(?:\\.(\\d+))?(?:\\.(\\d+))?$");
#endif
                int major = 0, minor = 0, patch = 0;
                string libruby;
                directory::each_file(libdir.string(), [&](string const& file) {
                    // Ignore symlinks
                    if (is_symlink(file, ec)) {
                        return true;
                    }

                    // Extract the version from the file name
                    // These are strings and not integers because the match groups are optional
                    int current_major = 0, current_minor = 0, current_patch = 0;
                    if (!re_search(file, regex, &current_major, &current_minor, &current_patch)) {
                        return true;
                    }

                    if (current_major == 1 && current_minor == 8) {
                        LOG_DEBUG("ruby library at %1% will be skipped: ruby 1.8 is not supported.", file);
                        return true;
                    }

                    // Check to see if the given version is greater than or equal to the current version
                    // This is done so that if all strings are empty (i.e. we've found only libruby.so),
                    // we set libruby to the file that was found.
                    if (tie(current_major, current_minor, current_patch) >= tie(major, minor, patch)) {
                        tie(major, minor, patch) = tie(current_major, current_minor, current_patch);
                        libruby = file;
                        LOG_DEBUG("found candidate ruby library %1%.", file);
                    } else {
                        LOG_DEBUG("ruby library %1% has a higher version number than %2%.", libruby, file);
                    }
                    return true;
                }, "libruby.*\\.(?:so|dylib)");

                if (!libruby.empty() && library.load(libruby)) {
                    return library;
                }
            } else {
              LOG_DEBUG("ruby library not found at %1%: %2%", path(ruby).remove_filename() / ".." / "lib", ec.message());
            }
        } else {
            LOG_DEBUG("ruby could not be found on the PATH.");
        }
        return library;
    }

}}  // namespace facter::ruby
