#include <facter/ruby/api.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/regex.hpp>
#include <facter/util/environment.hpp>
#include <facter/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>

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
                LOG_WARNING("ruby library \"%1%\" could not be loaded.", value);
            }
        }

        // First try supporting rbenv
        string ruby;
        auto result = execution::execute("rbenv", { "which", "ruby" });
        if (result.first) {
            ruby = result.second;
        }

        if (ruby.empty()) {
            // Next search the PATH
            ruby = execution::which("ruby");
            if (ruby.empty()) {
                LOG_DEBUG("ruby could not be found on the PATH.");
                return library;
            }
        }

        LOG_DEBUG("ruby was found at \"%1%\".", ruby);

        path parent_path = path(ruby).remove_filename() / "..";
        path lib_path = parent_path / "lib64";

        boost::system::error_code ec;
        path search_path  = canonical(lib_path, ec);
        if (ec) {
            LOG_DEBUG("ruby library was not found at %1%: %2%.", lib_path, ec.message());
            lib_path = parent_path / "lib";
            search_path  = canonical(lib_path, ec);
            if (ec) {
                LOG_DEBUG("ruby library was not found at %1%: %2%.", lib_path, ec.message());
                return library;
            }
        }

        LOG_DEBUG("searching %1% for ruby libraries.", search_path);

        int major = 0, minor = 0, patch = 0;
        string libruby;

        // Search the library directory for the "latest" libruby
#if __APPLE__ && __MACH__
        re_adapter regex("libruby(?:[-.](\\d+))?(?:\\.(\\d+))?(?:\\.(\\d+))?\\.dylib$");
#else
        // Matches either libruby.so<version> or libruby-*.so<version>
        re_adapter regex("libruby(?:-.*)?\\.so(?:\\.(\\d+))?(?:\\.(\\d+))?(?:\\.(\\d+))?$");
#endif

        directory::each_file(search_path.string(), [&](string const &file) {
            // Ignore symlinks
            if (is_symlink(file, ec)) {
                return true;
            }

            // Ignore static libs, but notify the user
            if (boost::ends_with(file, ".a")) {
                LOG_DEBUG("ruby library \"%1%\" is not supported: ensure ruby was built with the --enable-shared configuration option.", file);
                return true;
            }

            // Extract the version from the file name
            int current_major = 0, current_minor = 0, current_patch = 0;
            if (!re_search(file, regex, &current_major, &current_minor, &current_patch)) {
                return true;
            }

            if (current_major == 1 && current_minor == 8) {
                LOG_DEBUG("ruby library at \"%1%\" will be skipped: ruby 1.8 is not supported.", file);
                return true;
            }

            // Check to see if the given version is greater than or equal to the current version
            // This is done so that if all strings are empty (i.e. we've found only libruby.so),
            // we set libruby to the file that was found.
            if (tie(current_major, current_minor, current_patch) >= tie(major, minor, patch)) {
                tie(major, minor, patch) = tie(current_major, current_minor, current_patch);
                libruby = file;
                LOG_DEBUG("found candidate ruby library \"%1%\".", file);
            } else {
                LOG_DEBUG("ruby library \"%1%\" has a higher version number than \"%2%\".", libruby, file);
            }
            return true;
        }, "libruby.*\\.(?:so|dylib|a)");

        // If we found a ruby, attempt to load it
        if (!libruby.empty()) {
            library.load(libruby);
        }
        return library;
    }

}}  // namespace facter::ruby
