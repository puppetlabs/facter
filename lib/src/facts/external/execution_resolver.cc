#include <internal/facts/external/execution_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <internal/util/yaml.hpp>

#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <yaml-cpp/yaml.h>

using namespace std;
using namespace leatherman::execution;
using namespace facter::facts;
using namespace facter::facts::external;
using namespace facter::util::yaml;

namespace facter { namespace facts { namespace external {

    void execution_resolver::resolve(collection& facts)
    {
        LOG_DEBUG("resolving facts from executable file \"{1}\".", _path);

        try
        {
            bool resolved = false;
            auto result = execute(_path, 0,
                {
                    execution_options::trim_output,
                    execution_options::merge_environment,
                    execution_options::throw_on_failure,
                    execution_options::convert_newlines
                });

            try {
                auto node = YAML::Load(result.output);
                for (auto const& kvp : node) {
                    add_value(kvp.first.as<string>(), kvp.second, facts, _names);

                    // If YAML doesn't correctly parse, it will
                    // sometimes just return an empty node instead of
                    // erroring. Only claiming we've resolved if we
                    // add at least one child value from the YAML
                    // allows us to still pass on to the keyval
                    // interpretation in those cases.
                    resolved = true;
                }
            }  catch (YAML::Exception& ex) {
                LOG_DEBUG("Could not parse executable fact output as YAML or JSON ({1})", ex.msg);
            }

            if (!resolved) {
                std::vector<string> lines;
                boost::split(lines, result.output, boost::is_any_of("\n"));
                for (const auto& line : lines) {
                    auto pos = line.find('=');
                    if (pos == string::npos) {
                        LOG_DEBUG("ignoring line in output: {1}", line);
                        continue;
                    }
                    // Add as a string fact
                    string fact = line.substr(0, pos);
                    boost::to_lower(fact);
                    _names.push_back(fact);
                    facts.add_external(move(fact), make_value<string_value>(line.substr(pos+1)));
                }
            }

            // Log a warning if there is error output from the command
            if (!result.error.empty()) {
                LOG_WARNING("external fact file \"{1}\" had output on stderr: {2}", _path, result.error);
            }
        }
        catch (execution_exception& ex) {
            throw external_fact_exception(ex.what());
        }

        LOG_DEBUG("completed resolving facts from executable file \"{1}\".", _path);
    }

}}}  // namespace facter::facts::external
