#include <facter/execution/execution.hpp>
#include <facter/util/directory.hpp>
#include <facter/util/string.hpp>
#include <facter/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <cstring>

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

    string which(string const& file, vector<string> const& directories)
    {
        // TODO WINDOWS: implement function.
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
