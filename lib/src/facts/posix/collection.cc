#include <facter/facts/collection.hpp>
#include <leatherman/util/environment.hpp>
#include <unistd.h>
#include <vector>
#include <string>
#include <cstdlib>
#include <memory>

using namespace std;
using namespace leatherman::util;
using namespace facter::facts::external;

namespace facter { namespace facts {

    vector<string> collection::get_external_fact_directories() const
    {
        vector<string> directories;
        if (getuid()) {
            string home;
            if (environment::get("HOME", home)) {
                directories.emplace_back(home + "/.puppetlabs/opt/facter/facts.d");
                directories.emplace_back(home + "/.facter/facts.d");
            }
        } else {
            directories.emplace_back("/opt/puppetlabs/facter/facts.d");
            directories.emplace_back("/etc/facter/facts.d");
            directories.emplace_back("/etc/puppetlabs/facter/facts.d");
        }
        return directories;
    }

}}  // namespace facter::facts
