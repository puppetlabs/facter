#include <facter/facts/linux/lsb_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>
#include <re2/re2.h>

using namespace std;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace facts { namespace linux {

    lsb_resolver::lsb_resolver() :
        resolver(
            "Linux Standard Base",
            {
                fact::lsb_dist_id,
                fact::lsb_dist_release,
                fact::lsb_dist_codename,
                fact::lsb_dist_description,
                fact::lsb_dist_major_release,
                fact::lsb_dist_minor_release,
                fact::lsb_release,
            })
    {
    }

    void lsb_resolver::resolve_facts(collection& facts)
    {
        // Resolve all lsb-related facts
        resolve_dist_id(facts);
        resolve_dist_release(facts);
        resolve_dist_codename(facts);
        resolve_dist_description(facts);
        resolve_dist_version(facts);
        resolve_release(facts);
    }

    void lsb_resolver::resolve_dist_id(collection& facts)
    {
        auto result = execute("lsb_release", {"-i", "-s"});
        if (!result.first || result.second.empty()) {
            return;
        }
        facts.add(fact::lsb_dist_id, make_value<string_value>(move(result.second)));
    }

    void lsb_resolver::resolve_dist_release(collection& facts)
    {
        auto result = execute("lsb_release", {"-r", "-s"});
        if (!result.first || result.second.empty()) {
            return;
        }
        facts.add(fact::lsb_dist_release, make_value<string_value>(move(result.second)));
    }

    void lsb_resolver::resolve_dist_codename(collection& facts)
    {
        auto result = execute("lsb_release", {"-c", "-s"});
        if (!result.first || result.second.empty()) {
            return;
        }
        facts.add(fact::lsb_dist_codename, make_value<string_value>(move(result.second)));
    }

    void lsb_resolver::resolve_dist_description(collection& facts)
    {
        auto result = execute("lsb_release", {"-d", "-s"});
        if (!result.first || result.second.empty()) {
            return;
        }

        // The value may be quoted; trim the quotes
        facts.add(fact::lsb_dist_description, make_value<string_value>(trim(move(result.second), { '\"' })));
    }

    void lsb_resolver::resolve_dist_version(collection& facts)
    {
        auto dist_release = facts.get<string_value>(fact::lsb_dist_release, false);
        if (!dist_release) {
            return;
        }
        string major;
        string minor;
        if (!RE2::PartialMatch(dist_release->value(), "(\\d+)\\.(\\d*)", &major, &minor)) {
            major = dist_release->value();
        }
        facts.add(fact::lsb_dist_major_release, make_value<string_value>(move(major)));

        if (!minor.empty()) {
            facts.add(fact::lsb_dist_minor_release, make_value<string_value>(move(minor)));
        }
    }

    void lsb_resolver::resolve_release(collection& facts)
    {
        auto result = execute("lsb_release", {"-v", "-s"});
        if (!result.first || result.second.empty()) {
            return;
        }
        facts.add(fact::lsb_release, make_value<string_value>(move(result.second)));
    }

}}}  // namespace facter::facts::linux
