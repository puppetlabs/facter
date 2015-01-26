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

namespace facter { namespace ruby {

    dynamic_library api::find_library()
    {
        const string libruby_pattern = ".*ruby(\\d)?(\\d)?(\\d)?\\.dll";
        // 1. Use dynamic_library::find_by_pattern to see if a DLL is already loaded
        dynamic_library library = dynamic_library::find_by_pattern(libruby_pattern);
        if (library.loaded()) {
            return library;
        }

        // 2. Check the FACTERRUBY environment variable
        string value;
        if (environment::get("FACTERRUBY", value)) {
            if (library.load(value)) {
                return library;
            } else {
                LOG_WARNING("ruby library %1% could not be loaded.", value);
            }
        }

        // 3. Search the path for ruby.exe and look in the same directory for the ruby dll.
        string ruby = execution::which("ruby");
        if (!ruby.empty()) {
            boost::system::error_code ec;
            path libdir = canonical(path(ruby).remove_filename(), ec);
            if (!ec) {
                LOG_DEBUG("searching %1% for ruby libraries.", libdir);

                // Search the library directory for the "latest" libruby
                // Windows ruby builds use xxx for major/minor/patch versions, i.e. ruby193.dll
                re_adapter regex(libruby_pattern);
                int major = 0, minor = 0, patch = 0;
                string libruby;
                directory::each_file(libdir.string(), [&](string const& file) {
                    // Ignore symlinks
                    if (is_symlink(file, ec)) {
                        return true;
                    }

                    // Extract the version from the file name
                    int current_major = 0, current_minor = 0, current_patch = 0;
                    if (!re_search(file, regex, &current_major, &current_minor, &current_patch)) {
                        return true;
                    }

                    if (current_major == 1 && current_minor == 8) {
                        LOG_DEBUG("ruby library at %1% will be skipped: ruby 1.8 is not supported.", file);
                        return true;
                    }

                    // Use >= to allow for them to be empty; if no version numbers are matched the last lib is selected.
                    if (tie(current_major, current_minor, current_patch) >= tie(major, minor, patch)) {
                        tie(major, minor, patch) = tie(current_major, current_minor, current_patch);
                        libruby = file;
                        LOG_DEBUG("found candidate ruby library %1%.", file);
                    } else {
                        LOG_DEBUG("ruby library %1% has a higher version number than %2%.", libruby, file);
                    }
                    return true;
                }, libruby_pattern);

                if (!libruby.empty() && library.load(libruby)) {
                    return library;
                }
            } else {
              LOG_DEBUG("ruby library not found at %1%: %2%", path(ruby).remove_filename(), ec.message());
            }
        } else {
            LOG_DEBUG("ruby could not be found on the PATH.");
        }
        return library;
    }

}}  // namespace facter::ruby
