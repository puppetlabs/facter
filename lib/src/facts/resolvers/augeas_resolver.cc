#include <internal/facts/resolvers/augeas_resolver.hpp>
#include <internal/util/agent.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/util/regex.hpp>

using namespace std;
using namespace facter::util;
using namespace leatherman::util;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace resolvers {

    augeas_resolver::augeas_resolver() :
        resolver(
            "augeas",
            {
                fact::augeas,
                fact::augeasversion,
            })
    {
    }

    string augeas_resolver::get_version()
    {
        string augparse = agent::which("augparse");
        string value;
        boost::regex regexp("^augparse (\\d+\\.\\d+\\.\\d+)");
        // Version info goes on stderr.
        each_line(augparse, {"--version"}, nullptr, [&](string& line) {
            if (re_search(line, regexp, &value)) {
                return false;
            }
            return true;
        });
        return value;
    }

    void augeas_resolver::resolve(collection& facts)
    {
        auto version = get_version();
        if (version.empty()) {
            return;
        }

        auto augeas = make_value<map_value>();
        augeas->add("version", make_value<string_value>(version));
        facts.add(fact::augeasversion, make_value<string_value>(move(version), true));
        facts.add(fact::augeas, move(augeas));
    }

}}}  // namespace facter::facts::resolvers
