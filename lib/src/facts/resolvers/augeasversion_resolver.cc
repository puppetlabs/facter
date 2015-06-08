#include <internal/facts/resolvers/augeasversion_resolver.hpp>
#include <internal/util/regex.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace resolvers {

    augeasversion_resolver::augeasversion_resolver() :
        resolver(
            "augeasversion",
            {
                fact::augeasversion
            })
    {
    }

    string augeasversion_resolver::get_version()
    {
        string augtool = [] {
#ifdef FACTER_PATH
            string fixed = execution::which("augtool", {FACTER_PATH});
            if (fixed.empty()) {
                LOG_WARNING("augtool not found at configured location %1%, using PATH instead", FACTER_PATH);
            } else {
                return fixed;
            }
#endif
            return string("augtool");
        }();

        string value;
        boost::regex regexp("^augtool (\\d+\\.\\d+\\.\\d+)");
        // Version info goes on stderr.
        execution::each_line(augtool, {"--version"}, nullptr, [&](string& line) {
            if (re_search(line, regexp, &value)) {
                return false;
            }
            return true;
        });
        return value;
    }

    void augeasversion_resolver::resolve(collection& facts)
    {
        auto version = get_version();
        if (version.empty()) {
            return;
        }

        facts.add(fact::augeasversion, make_value<string_value>(move(version)));
    }

}}}  // namespace facter::facts::resolvers
