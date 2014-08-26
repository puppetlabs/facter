#include <facter/facts/collection.hpp>
#include <facter/facts/external/json_resolver.hpp>
#include <facter/facts/external/text_resolver.hpp>
#include <facter/facts/external/yaml_resolver.hpp>
#include <facter/facts/external/execution_resolver.hpp>
#include <facter/util/environment.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::facts::external;

namespace facter { namespace facts {

    vector<string> collection::get_external_fact_directories()
    {
        // TODO WINDOWS: Implement function.
        return vector<string>();
    }

    vector<unique_ptr<external::resolver>> collection::get_external_resolvers()
    {
        // TODO WINDOWS: Implement function.
        return vector<unique_ptr<external::resolver>>();
    }

    void collection::add_platform_facts()
    {
        // TODO WINDOWS: Add facts as created.
    }

}}  // namespace facter::facts
