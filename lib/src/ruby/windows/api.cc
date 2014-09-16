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

LOG_DECLARE_NAMESPACE("ruby");

namespace facter { namespace ruby {

    dynamic_library api::find_library()
    {
        // 1. Use dynamic_library::find_by_name (change it to support regex pattern and use CreateToolhelp32Snapshot to implement)
        dynamic_library library = dynamic_library::find_by_symbol("ruby_init");
        if (library.loaded()) {
            return library;
        }

        // 2. Check the FACTER_RUBY environment variable
        string value;
        if (environment::get("FACTER_RUBY", value)) {
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
                re_adapter regex(".*ruby(\\d)?(\\d)?(\\d)?\\.dll");
                string major, minor, patch, libruby;
                directory::each_file(libdir.string(), [&](string const& file) {
                    // Ignore symlinks
                    if (is_symlink(file, ec)) {
                        return true;
                    }

                    // Extract the version from the file name
                    string current_major, current_minor, current_patch;
                    if (!re_search(file, regex, &current_major, &current_minor, &current_patch)) {
                        return true;
                    }

                    if (current_major == "1" && current_minor == "8") {
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
                }, ".*ruby.*\\.dll");

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
