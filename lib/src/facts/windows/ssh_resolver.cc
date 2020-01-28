#include <internal/facts/windows/ssh_resolver.hpp>
#include <leatherman/file_util/file.hpp>
#include <facter/util/string.hpp>

#include <leatherman/util/environment.hpp>
#include <leatherman/windows/file_util.hpp>
#include <leatherman/windows/system_error.hpp>
#include <leatherman/windows/user.hpp>
#include <leatherman/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/format.hpp>
#include <tuple>
#include <vector>

#ifdef USE_OPENSSL
#include <internal/util/scoped_bio.hpp>
#include <openssl/sha.h>
#include <openssl/evp.h>
using namespace facter::util;
#endif  // USE_OPENSSL

using namespace std;
using namespace facter::util;
using namespace boost::filesystem;

namespace bs = boost::system;
namespace lth_file = leatherman::file_util;

using namespace leatherman::util;

namespace facter { namespace facts { namespace windows {

    ssh_resolver::data ssh_resolver::collect_data(collection& facts)
    {
        data result;
        populate_key("ssh_host_rsa_key.pub", 1, result.rsa);
        populate_key("ssh_host_dsa_key.pub", 2, result.dsa);
        populate_key("ssh_host_ecdsa_key.pub", 3, result.ecdsa);
        populate_key("ssh_host_ed25519_key.pub", 4, result.ed25519);
        return result;
    }

    void ssh_resolver::populate_key(std::string const& filename, int type, ssh_key& key)
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

        // Log if we didn't find the file
        if (key_file.empty()) {
            LOG_DEBUG("{1} could not be located.", filename);
            return;
        }

        // Read the file's contents
        string contents = lth_file::read(key_file.string());
        if (contents.empty()) {
            LOG_DEBUG("{1} could not be read.", key_file);
            return;
        }

        // The SSH public key file format is <algo> <key> <comment>
        vector<boost::iterator_range<string::iterator>> parts;
        boost::split(parts, contents, boost::is_any_of(" "), boost::token_compress_on);
        if (parts.size() < 2) {
            LOG_DEBUG("unexpected contents for {1}.", key_file);
            return;
        }

        // Assign the key and its type
        key.type.assign(parts[0].begin(), parts[0].end());
        key.key.assign(parts[1].begin(), parts[1].end());

        // Only fingerprint if we are using OpenSSL
#ifdef USE_OPENSSL
        // Decode the key which is expected to be base64 encoded
        vector<uint8_t> key_bytes(key.key.size());
        scoped_bio b64((BIO_f_base64()));
        BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);

        // Despite the const_cast here, we're only reading from the string; BIO_new_mem_buf is not const-correct
        scoped_bio mem(BIO_new_mem_buf(const_cast<char*>(key.key.c_str()), key.key.size()));
        BIO* stream = BIO_push(b64, mem);
        int length = BIO_read(stream, key_bytes.data(), key_bytes.size());
        if (length < 1) {
            LOG_DEBUG("failed to decode SSH key \"{1}\".", key.key);
            return;
        }

        // Do a SHA1 and a SHA-256 hash for the fingerprints
        uint8_t hash[SHA_DIGEST_LENGTH];
        SHA1(key_bytes.data(), length, hash);
        uint8_t hash256[SHA256_DIGEST_LENGTH];
        SHA256(key_bytes.data(), length, hash256);

        key.digest.sha1 = (boost::format("SSHFP %1% 1 %2%") % type % to_hex(hash, sizeof(hash))).str();
        key.digest.sha256 = (boost::format("SSHFP %1% 2 %2%") % type % to_hex(hash256, sizeof(hash256))).str();
#else
        LOG_INFO("facter was built without OpenSSL support: SSH fingerprint information is unavailable.");
#endif  // USE_OPENSSL
    }

}}}  // namespace facter::facts::windows
