#include <internal/facts/ssh_resolver.hpp>

#include <leatherman/util/environment.hpp>
#include <leatherman/windows/file_util.hpp>
#include <leatherman/windows/system_error.hpp>
#include <leatherman/windows/user.hpp>
#include <leatherman/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace boost::filesystem;
using namespace leatherman::util;

namespace bs = boost::system;

namespace facter { namespace facts {

    path ssh_resolver::retrieve_key_file(string const& filename)
    {
        string dataPath;

        if (!environment::get("programdata", dataPath)) {
            LOG_DEBUG("error finding programdata: {1}", leatherman::windows::system_error());
        }

        // https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement
        // Since there is no user associated with the sshd service, the host keys are stored under \ProgramData\ssh.
        string sshPath = ((path(dataPath) / "ssh").string());

        // Search in sshPath for the fact's key file
        path key_file;
        key_file = sshPath;
        key_file /= filename;

        bs::error_code ec;
        if (!is_regular_file(key_file, ec)) {
            key_file.clear();
        }

        return key_file;
    }

}}  // namespace facter::facts
