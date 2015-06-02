#include <facter/facts/collection.hpp>
#include <facter/util/environment.hpp>
#include <internal/facts/external/json_resolver.hpp>
#include <internal/facts/external/text_resolver.hpp>
#include <internal/facts/external/yaml_resolver.hpp>
#include <internal/facts/external/execution_resolver.hpp>
#include <unistd.h>
#include <vector>
#include <string>
#include <cstdlib>
#include <memory>

using namespace std;
using namespace facter::util;
using namespace facter::facts::external;

namespace facter { namespace facts {

    vector<string> collection::get_external_fact_directories()
    {
        vector<string> directories;
        if (getuid()) {
            string home;
            if (environment::get("HOME", home)) {
                directories.emplace_back(home + "/.puppetlabs/opt/facter/facts.d");
            }
        } else {
            directories.emplace_back("/opt/puppetlabs/facter/facts.d");
        }
        return directories;
    }

    vector<unique_ptr<external::resolver>> collection::get_external_resolvers()
    {
        vector<unique_ptr<external::resolver>> resolvers;
        resolvers.emplace_back(new text_resolver());
        resolvers.emplace_back(new yaml_resolver());
        resolvers.emplace_back(new json_resolver());

        // The execution resolver should go last as it doesn't check file extensions
        resolvers.emplace_back(new execution_resolver());
        return resolvers;
    }

}}  // namespace facter::facts
