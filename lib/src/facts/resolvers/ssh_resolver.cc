#include <internal/facts/resolvers/ssh_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>

using namespace std;

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

}}}  // namespace facter::facts::resolvers
