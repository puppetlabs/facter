#include <vector>
#include <string>
#include <cstdlib>
#include <unistd.h>
#include <boost/filesystem.hpp>

using namespace std;
using namespace boost::filesystem;

namespace facter { namespace facts {

    void populate_external_directories(vector<string>& directories)
    {
        if (getuid()) {
            auto home_dir = getenv("HOME");
            if (!home_dir) {
                return;
            }
            directories.emplace_back(string(home_dir) + "/.facter/facts.d");
        } else {
            directories.emplace_back("/etc/facter/facts.d");
            directories.emplace_back("/etc/puppetlabs/facter/facts.d");
        }
    }

}}  // namespace facter::facts
