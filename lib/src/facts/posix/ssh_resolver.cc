#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <facter/facts/posix/ssh_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/file.hpp>
#include <facter/util/string.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/format.hpp>
#include <tuple>
#include <vector>

#ifdef USE_OPENSSL
#include <facter/util/posix/scoped_bio.hpp>
#include <openssl/sha.h>
#include <openssl/evp.h>
using namespace facter::util::posix;
#endif  // USE_OPENSSL

using namespace std;
using namespace facter::util;
using namespace boost::filesystem;
namespace bs = boost::system;

LOG_DECLARE_NAMESPACE("facts.posix.ssh");

namespace facter { namespace facts { namespace posix {

    ssh_resolver::ssh_resolver() :
        resolver(
            "ssh",
            {
                fact::ssh_dsa_key,
                fact::ssh_rsa_key,
                fact::ssh_ecdsa_key,
                fact::ssh_ed25519_key,
                fact::sshfp_dsa,
                fact::sshfp_rsa,
                fact::sshfp_ecdsa,
                fact::sshfp_ed25519,
            })
    {
    }

    void ssh_resolver::resolve_facts(collection& facts)
    {
        static vector<tuple<string, string, string, int>> const ssh_facts = {
            make_tuple(string(fact::ssh_rsa_key), string(fact::sshfp_rsa), "ssh_host_rsa_key.pub", 1),
            make_tuple(string(fact::ssh_dsa_key), string(fact::sshfp_dsa), "ssh_host_dsa_key.pub", 2),
            make_tuple(string(fact::ssh_ecdsa_key), string(fact::sshfp_ecdsa), "ssh_host_ecdsa_key.pub", 3),
            make_tuple(string(fact::ssh_ed25519_key), string(fact::sshfp_ed25519), "ssh_host_ed25519_key.pub", 4),
        };

        static vector<string> const search_directories = {
            "/etc/ssh",
            "/usr/local/etc/ssh",
            "/etc",
            "/usr/local/etc",
            "/etc/opt/ssh"
        };

        // Go through each key fact above
        for (auto const& ssh_fact : ssh_facts) {
            auto const& ssh_fact_name = get<0>(ssh_fact);
            auto const& sshfp_fact_name = get<1>(ssh_fact);
            auto const& key_filename = get<2>(ssh_fact);

            // Search the directories for the fact's key file
            path key_file;
            for (auto const& directory : search_directories) {
                key_file = directory;
                key_file /= key_filename;

                bs::error_code ec;
                if (!is_regular_file(key_file, ec)) {
                    key_file.clear();
                    continue;
                }
                break;
            }

            // Log if we didn't find the file
            if (key_file.empty()) {
                LOG_DEBUG("%1% could not be located: fact %2% is unavailable.", key_filename, ssh_fact_name);
                continue;
            }

            // Read the file's contents
            string key = file::read(key_file.string());
            if (key.empty()) {
                LOG_DEBUG("%1% could not be read: fact %2% is unavailable.", key_file, ssh_fact_name);
                continue;
            }

            // The SSH file format should be <algo> <key> <hostname>
            vector<boost::iterator_range<string::iterator>> parts;
            boost::split(parts, key, boost::is_any_of(" "), boost::token_compress_on);
            if (parts.size() < 2) {
                LOG_DEBUG("unexpected contents for %1%: fact %2% is unavailable.", key_file, ssh_fact_name);
                continue;
            }

            // Add the key fact
            key.assign(parts[1].begin(), parts[1].end());
            facts.add(string(ssh_fact_name), make_value<string_value>(key));

            // Only fingerprint if we are using OpenSSL
#ifdef USE_OPENSSL
            auto finger_print_type = get<3>(ssh_fact);

            // Decode the key which is expected to be base64 encoded
            vector<uint8_t> key_bytes(key.size());
            scoped_bio b64((BIO_f_base64()));
            BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);

            // Despite the const_cast here, we're only reading from the string; BIO_new_mem_buf is not const-correct
            scoped_bio mem(BIO_new_mem_buf(const_cast<char*>(key.c_str()), key.size()));
            BIO* stream = BIO_push(b64, mem);
            int length = BIO_read(stream, key_bytes.data(), key.size());
            if (length < 1) {
                LOG_DEBUG("failed to decode SSH key: fact %1% is unavailable.", sshfp_fact_name);
                continue;
            }

            // Do a SHA1 and a SHA-256 hash for the fingerprints
            uint8_t hash[SHA_DIGEST_LENGTH];
            SHA1(key_bytes.data(), length, hash);
            uint8_t hash256[SHA256_DIGEST_LENGTH];
            SHA256(key_bytes.data(), length, hash256);

            // Add the key fingerprint fact
            facts.add(string(sshfp_fact_name),
                make_value<string_value>(
                    (boost::format("SSHFP %1% 1 %2%\nSSHFP %1% 2 %3%") %
                        finger_print_type %
                        to_hex(hash, sizeof(hash)) %
                        to_hex(hash256, sizeof(hash256))).str()));
#else
            LOG_INFO("fact \"%1%\" is unavailable: facter was built without OpenSSL support.", sshfp_fact_name);
#endif  // USE_OPENSSL
        }
    }

}}}  // namespace facter::facts::posix
