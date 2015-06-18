#include <internal/facts/aix/operating_system_resolver.hpp>
#include <internal/util/regex.hpp>
#include <facter/facts/os.hpp>
#include <facter/execution/execution.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/logging/logging.hpp>

#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::util;
using namespace leatherman::file_util;
using namespace boost;
namespace execution = facter::execution;

static string getattr(string object, string field)
{
    string result;

    execution::each_line(
        "/usr/sbin/lsattr", {"-El", object, "-a", field},
        [&](string& line) {
            if (!line.empty()) {
                vector<string> tokens;
                boost::split(tokens, line, boost::is_space(), boost::token_compress_on);
                if (tokens.size() < 2) {
                    return true;
                }
                result = tokens[1];
                return false;
            }
            return true;
        },
        nullptr,
        0);

    if (result == "") {
        LOG_WARNING("Could not get a value from lsattr -El %1% -a %2%", object, field);
    }
    return result;
}

namespace facter { namespace facts { namespace aix {

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        auto result = posix::operating_system_resolver::collect_data(facts);
        result.architecture = getattr("proc0", "type");
        result.hardware = getattr("sys0", "modelname");

        return result;
    }
}}}
