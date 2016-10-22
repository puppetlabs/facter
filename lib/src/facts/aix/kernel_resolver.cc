#include <internal/facts/aix/kernel_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/file_util/file.hpp>
#include <boost/regex.hpp>

using namespace leatherman::util;
using namespace leatherman::execution;
using namespace std;

namespace lth_file = leatherman::file_util;

static std::string parse_rml_cache() {
    const auto regex = boost::regex("^(\\d\\d-\\d+-\\d+)_SP.*Service Pack");
    string result;
    lth_file::each_line("/tmp/.oslevel.datafiles/.oslevel.rml.cache", [&](string& line) {
        string value;
        re_search(line, regex, &value);
        if (value > result) {
            result = value;
        }
        return true;
    });
    return result;
}

namespace facter { namespace facts { namespace aix   {

    kernel_resolver::data kernel_resolver::collect_data(collection& facts)
    {
        data result;

        // We reimplement part of oslevel here. We parse the rml cache
        // and use that to determine the full AIX system version. If
        // the rml cache doesn't exist, we just call out to oslevel to
        // regenerate it (since we're gonna be slow in that case
        // anyway).
        string version = parse_rml_cache();
        if (version.empty()) {
            auto exec = execute("/usr/bin/oslevel", {"-s"}, 0, { execution_options::trim_output, execution_options::redirect_stderr_to_stdout, execution_options::merge_environment });

            if (!exec.success) {
                LOG_WARNING("oslevel failed: {1}: kernel facts are unavailable", exec.output);
                return result;
            }

            version = parse_rml_cache();
            if (version.empty()) {
                LOG_WARNING("Could not parse rml cache even after regenerating with oslevel: kernel facts are unavailable. Try running 'oslevel -s' to debug.");
                return result;
            }
        }

        result.name = "AIX";
        result.version = version.substr(0, 2)+"00";
        result.release = version.substr(0, 2) + "00" + version.substr(2, 6) + "-" + version.substr(8, 4);
        return result;
    }

}}}  // namespace facter::facts::aix
