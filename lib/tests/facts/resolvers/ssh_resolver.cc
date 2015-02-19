#include <catch.hpp>
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

SCENARIO("using the ssh resolver") {
    collection facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_ssh_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0);
        }
    }
    WHEN("data is present") {
        static const vector<string> algorithms = {
            "dsa",
            "ecdsa",
            "ed25519",
            "rsa"
        };
        facts.add(make_shared<test_ssh_resolver>());
        THEN("a structured fact is added") {
            REQUIRE(facts.size() == 9);
            auto ssh = facts.get<map_value>(fact::ssh);
            REQUIRE(ssh);
            REQUIRE(ssh->size() == 4);
            for (auto const& algorithm : algorithms) {
                auto entry = ssh->get<map_value>(algorithm);
                REQUIRE(entry);
                REQUIRE(entry->size() == 2);
                auto key = entry->get<string_value>("key");
                REQUIRE(key);
                REQUIRE(key->value() == algorithm + ":key");
                auto fingerprints = entry->get<map_value>("fingerprints");
                REQUIRE(fingerprints);
                REQUIRE(fingerprints->size() == 2);
                auto fingerprint = fingerprints->get<string_value>("sha1");
                REQUIRE(fingerprint);
                REQUIRE(fingerprint->value() == algorithm + ":sha1");
                fingerprint = fingerprints->get<string_value>("sha256");
                REQUIRE(fingerprint);
                REQUIRE(fingerprint->value() == algorithm + ":sha256");
            }
        }
        THEN("flat facts are added") {
            REQUIRE(facts.size() == 9);
            for (auto const& algorithm : algorithms) {
                auto key = facts.get<string_value>("ssh" + algorithm + "key");
                REQUIRE(key);
                REQUIRE(key->value() == algorithm + ":key");
                auto fingerprint = facts.get<string_value>("sshfp_" + algorithm);
                REQUIRE(fingerprint);
                REQUIRE(fingerprint->value() == algorithm + ":sha1\n" + algorithm + ":sha256");
            }
        }
    }
}
