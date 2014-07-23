#include <facter/util/directory.hpp>
#include <boost/filesystem.hpp>
#include <re2/re2.h>

using namespace std;
using namespace re2;
using namespace boost::filesystem;

namespace facter { namespace util {

    void directory::each_file(string const& directory, function<bool(string const&)> callback, string const& pattern)
    {
        RE2 regex(pattern);
        if (!regex.ok()) {
            return;
        }

        // Attempt to iterate the directory
        boost::system::error_code ec;
        directory_iterator it = directory_iterator(directory, ec);
        if (ec) {
            return;
        }

        // Call the callback for any matching files
        directory_iterator end;
        for (; it != end; ++it) {
            boost::system::error_code ec;
            if (!is_regular_file(it->status(ec))) {
                continue;
            }
            if (RE2::PartialMatch(it->path().filename().string(), regex)) {
                if (!callback(it->path().string())) {
                    break;
                }
            }
        }
    }

    void directory::each_subdirectory(string const& directory, function<bool(string const&)> callback, string const& pattern)
    {
        RE2 regex(pattern);
        if (!regex.ok()) {
            return;
        }

        // Attempt to iterate the directory
        boost::system::error_code ec;
        directory_iterator it = directory_iterator(directory, ec);
        if (ec) {
            return;
        }

        // Call the callback for any matching subdirectories
        directory_iterator end;
        for (; it != end; ++it) {
            boost::system::error_code ec;
            if (!is_directory(it->status(ec))) {
                continue;
            }
            if (RE2::PartialMatch(it->path().filename().string(), regex)) {
                if (!callback(it->path().string())) {
                    break;
                }
            }
        }
    }

}}  // namespace facter::util
