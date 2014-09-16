#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/environment.hpp>
#include <facter/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string/split.hpp>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <cstring>
#include <windows.h>

using namespace std;
using namespace facter::util;
using namespace facter::logging;
using namespace boost::filesystem;

LOG_DECLARE_NAMESPACE("execution");

namespace facter { namespace execution {

    uint64_t get_max_descriptor_limit()
    {
        // TODO WINDOWS: implement function.
        return 0;
    }

    struct extpath_helper
    {
        extpath_helper()
        {
            string extpaths;
            if (environment::get("PATHEXT", extpaths)) {
                wstring wextpaths(extpaths.begin(), extpaths.end());
                boost::split(_extpaths, wextpaths, bind(equal_to<char>(), placeholders::_1, environment::get_path_separator()), boost::token_compress_on);
            } else {
                _extpaths = {L".BAT", L".CMD", L".COM", L".EXE"};
            }
            sort(_extpaths.begin(), _extpaths.end());
        }

        vector<wstring> const& ext_paths() const
        {
            return _extpaths;
        }

        bool contains(const wstring & ext) const
        {
            return binary_search(_extpaths.begin(), _extpaths.end(), ext);
        }

     private:
         vector<wstring> _extpaths;
    };

    static bool is_executable(path const& p, extpath_helper const* helper = nullptr)
    {
        // If there's an error accessing file status, we assume is_executable
        // is false and return. The reason for failure doesn't matter to us.
        boost::system::error_code ec;
        bool isfile = is_regular_file(p, ec);
        if (ec) {
            LOG_TRACE("error reading status of path %1%: %2% (%3%)", p, ec.message(), ec.value());
        }

        if (helper) {
            // Checking extensions aren't needed if we explicitly specified it.
            // If helper was passed, then we haven't and should check the ext.
            isfile &= helper->contains(p.extension().native());
        }
        return isfile;
    }

    string which(string const& file, vector<string> const& directories)
    {
        // On Windows, everything has execute permission; Ruby determined
        // executability based on extension {com, exe, bat, cmd}. We'll do the
        // same check here using extpath_helper.
        static extpath_helper helper;

        // If the file is already absolute, return it if it's executable.
        path p = file;
        if (p.is_absolute()) {
            return is_executable(p, &helper) ? p.string() : string();
        }

        // Otherwise, check for an executable file under the given search paths
        for (auto const& dir : directories) {
            path p = path(dir) / file;
            if (!p.has_extension()) {
                path pext = p;
                for (auto const&ext : helper.ext_paths()) {
                    pext.replace_extension(ext);
                    if (is_executable(pext)) {
                        return pext.string();
                    }
                }
            }
            if (is_executable(p, &helper)) {
                return p.string();
            }
        }
        return {};
    }

    pair<bool, string> execute(
        string const& file,
        vector<string> const* arguments,
        map<string, string> const* environment,
        function<bool(string&)> callback,
        option_set<execution_options> const& options)
    {
        // TODO WINDOWS: implement function.
        return { false, "" };
    }

}}  // namespace facter::executions
