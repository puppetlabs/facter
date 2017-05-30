#include <internal/facts/aix/kernel_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/file_util/file.hpp>
#include <boost/regex.hpp>

using namespace leatherman::execution;
using namespace std;

namespace facter { namespace facts { namespace aix   {

    kernel_resolver::data kernel_resolver::collect_data(collection& facts)
    {
        data result;

        auto exec = execute("/usr/bin/oslevel", {"-s"}, 0, { execution_options::trim_output, execution_options::redirect_stderr_to_stdout, execution_options::merge_environment });

        result.name = "AIX";
        result.release = exec.output;
        result.version = exec.output.substr(0, 4);

        return result;
    }

}}}  // namespace facter::facts::aix
