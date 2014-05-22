#include <facter/facts/external/json_resolver.hpp>
#include <facter/facts/external/yaml_resolver.hpp>
#include <facter/facts/external/posix/execution_resolver.hpp>
#include <vector>
#include <string>
#include <cstdlib>
#include <unistd.h>
#include <memory>
#include <boost/filesystem.hpp>

using namespace std;
using namespace boost::filesystem;
using namespace facter::facts::external;
using namespace facter::facts::external::posix;

namespace facter { namespace facts {

    vector<string> get_external_directories()
    {
        vector<string> directories;
        if (getuid()) {
            auto home_dir = getenv("HOME");
            if (home_dir) {
                directories.emplace_back(string(home_dir) + "/.facter/facts.d");
            }
        } else {
            directories.emplace_back("/etc/facter/facts.d");
            directories.emplace_back("/etc/puppetlabs/facter/facts.d");
        }
        return directories;
    }

    vector<unique_ptr<resolver>> get_external_resolvers()
    {
        vector<unique_ptr<resolver>> resolvers;
        resolvers.emplace_back(new yaml_resolver());
        resolvers.emplace_back(new json_resolver());

        // The execution resolver should go last as it doesn't check file extensions
        resolvers.emplace_back(new execution_resolver());
        return resolvers;
    }

}}  // namespace facter::facts
