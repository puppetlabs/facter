#include <gmock/gmock.h>
#include <facter/facts/resolvers/ssh_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_ssh_resolver : ssh_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_ssh_resolver : ssh_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.dsa.key = "dsa:key";
        result.dsa.digest.sha1 = "dsa:sha1";
        result.dsa.digest.sha256 = "dsa:sha256";
        result.ecdsa.key = "ecdsa:key";
        result.ecdsa.digest.sha1 = "ecdsa:sha1";
        result.ecdsa.digest.sha256 = "ecdsa:sha256";
        result.ed25519.key = "ed25519:key";
        result.ed25519.digest.sha1 = "ed25519:sha1";
        result.ed25519.digest.sha256 = "ed25519:sha256";
        result.rsa.key = "rsa:key";
        result.rsa.digest.sha1 = "rsa:sha1";
        result.rsa.digest.sha256 = "rsa:sha256";
        return result;
    }
};

TEST(facter_facts_resolvers_ssh_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_ssh_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_ssh_resolver, facts)
{
    collection facts;
    facts.add(make_shared<test_ssh_resolver>());
    ASSERT_EQ(9u, facts.size());

    auto key = facts.get<string_value>(fact::ssh_dsa_key);
    ASSERT_NE(nullptr, key);
    ASSERT_EQ("dsa:key", key->value());

    auto fingerprint = facts.get<string_value>(fact::sshfp_dsa);
    ASSERT_NE(nullptr, fingerprint);
    ASSERT_EQ("dsa:sha1\ndsa:sha256", fingerprint->value());

    key = facts.get<string_value>(fact::ssh_ecdsa_key);
    ASSERT_NE(nullptr, key);
    ASSERT_EQ("ecdsa:key", key->value());

    fingerprint = facts.get<string_value>(fact::sshfp_ecdsa);
    ASSERT_NE(nullptr, fingerprint);
    ASSERT_EQ("ecdsa:sha1\necdsa:sha256", fingerprint->value());

    key = facts.get<string_value>(fact::ssh_ed25519_key);
    ASSERT_NE(nullptr, key);
    ASSERT_EQ("ed25519:key", key->value());

    fingerprint = facts.get<string_value>(fact::sshfp_ed25519);
    ASSERT_NE(nullptr, fingerprint);
    ASSERT_EQ("ed25519:sha1\ned25519:sha256", fingerprint->value());

    key = facts.get<string_value>(fact::ssh_rsa_key);
    ASSERT_NE(nullptr, key);
    ASSERT_EQ("rsa:key", key->value());

    fingerprint = facts.get<string_value>(fact::sshfp_rsa);
    ASSERT_NE(nullptr, fingerprint);
    ASSERT_EQ("rsa:sha1\nrsa:sha256", fingerprint->value());

    auto ssh = facts.get<map_value>(fact::ssh);
    ASSERT_NE(nullptr, ssh);
    ASSERT_EQ(4u, ssh->size());

    vector<string> algorithms = {
        "dsa",
        "ecdsa",
        "ed25519",
        "rsa"
    };

    for (auto const &name : algorithms) {
        auto algorithm = ssh->get<map_value>(name);
        ASSERT_NE(nullptr, algorithm);
        ASSERT_EQ(2u, algorithm->size());

        key = algorithm->get<string_value>("key");
        ASSERT_NE(nullptr, key);
        ASSERT_EQ(name + ":key", key->value());

        auto fingerprints = algorithm->get<map_value>("fingerprints");
        ASSERT_NE(nullptr, fingerprints);
        ASSERT_EQ(2u, fingerprints->size());

        fingerprint = fingerprints->get<string_value>("sha1");
        ASSERT_NE(nullptr, fingerprint);
        ASSERT_EQ(name + ":sha1", fingerprint->value());

        fingerprint = fingerprints->get<string_value>("sha256");
        ASSERT_NE(nullptr, fingerprint);
        ASSERT_EQ(name + ":sha256", fingerprint->value());
    }
}
