#include <internal/facts/resolvers/ssh_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

#include <facter/util/string.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/format.hpp>

#ifdef USE_OPENSSL
#include <internal/util/scoped_bio.hpp>
#include <openssl/sha.h>
#include <openssl/evp.h>
using namespace facter::util;
#endif  // USE_OPENSSL

using namespace std;
using namespace facter::util;
using namespace boost::filesystem;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace resolvers {

    ssh_resolver::ssh_resolver() :
        resolver(
            "ssh",
            {
                fact::ssh,
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

    ssh_resolver::data ssh_resolver::collect_data(collection& facts)
    {
        ssh_resolver::data result;
        populate_key("ssh_host_rsa_key.pub", 1, result.rsa);
        populate_key("ssh_host_dsa_key.pub", 2, result.dsa);
        populate_key("ssh_host_ecdsa_key.pub", 3, result.ecdsa);
        populate_key("ssh_host_ed25519_key.pub", 4, result.ed25519);
        return result;
    }

    void ssh_resolver::resolve(collection& facts)
    {
        auto data = collect_data(facts);

        auto ssh = make_value<map_value>();
        add_key(facts, *ssh, data.dsa, "dsa", fact::ssh_dsa_key, fact::sshfp_dsa);
        add_key(facts, *ssh, data.rsa, "rsa", fact::ssh_rsa_key, fact::sshfp_rsa);
        add_key(facts, *ssh, data.ecdsa, "ecdsa", fact::ssh_ecdsa_key, fact::sshfp_ecdsa);
        add_key(facts, *ssh, data.ed25519, "ed25519", fact::ssh_ed25519_key, fact::sshfp_ed25519);

        if (!ssh->empty()) {
            facts.add(fact::ssh, move(ssh));
        }
    }

    void ssh_resolver::add_key(collection& facts, map_value& value, ssh_key& key, string const& name, string const& key_fact_name, string const& fingerprint_fact_name)
    {
        if (key.key.empty()) {
            return;
        }

        auto key_value = make_value<map_value>();
        auto fingerprint_value = make_value<map_value>();

        facts.add(string(key_fact_name), make_value<string_value>(key.key, true));
        key_value->add("key", make_value<string_value>(move(key.key)));
        key_value->add("type", make_value<string_value>(move(key.type)));

        string fingerprint;
        if (!key.digest.sha1.empty()) {
            fingerprint = key.digest.sha1;
            fingerprint_value->add("sha1", make_value<string_value>(move(key.digest.sha1)));
        }
        if (!key.digest.sha256.empty()) {
            if (!fingerprint.empty()) {
                fingerprint += "\n";
            }
            fingerprint += key.digest.sha256;
            fingerprint_value->add("sha256", make_value<string_value>(move(key.digest.sha256)));
        }
        if (!fingerprint.empty()) {
            facts.add(string(fingerprint_fact_name), make_value<string_value>(move(fingerprint), true));
        }
        if (!fingerprint_value->empty()) {
            key_value->add("fingerprints", move(fingerprint_value));
        }

        value.add(string(name), move(key_value));
    }

    void ssh_resolver::populate_key(std::string const& filename, int type, ssh_key& key)
    {
        path key_file = retrieve_key_file(filename);

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

        boost::trim(contents);
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

}}}  // namespace facter::facts::resolvers
