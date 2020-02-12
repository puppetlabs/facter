#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <internal/facts/ssh_resolver.hpp>

using namespace std;
using namespace boost::filesystem;

namespace bs = boost::system;

namespace facter { namespace facts {

    path ssh_resolver::retrieve_key_file(string const& filename)
    {
        path key_file;

        static vector<string> const search_directories = {
            "/etc/ssh",
            "/usr/local/etc/ssh",
            "/etc",
            "/usr/local/etc",
            "/etc/opt/ssh"
        };

        for (auto const& directory : search_directories) {
            key_file = directory;
            key_file /= filename;

            bs::error_code ec;
            if (!is_regular_file(key_file, ec)) {
                key_file.clear();
                continue;
            }
            break;
        }

        return key_file;
    }

}}  // namespace facter::facts
