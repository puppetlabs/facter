#include <facts/fact_map.hpp>
#include <facts/linux/lsb_resolver.hpp>
#include <facts/string_value.hpp>
#include <execution/execution.hpp>
#include <util/string.hpp>
#include <re2/re2.h>

using namespace std;
using namespace cfacter::util;
using namespace cfacter::execution;

namespace cfacter { namespace facts { namespace linux {

    void lsb_resolver::resolve_facts(fact_map& facts)
    {
        // Resolve all lsb-related facts
        resolve_dist_id(facts);
        resolve_dist_release(facts);
        resolve_dist_codename(facts);
        resolve_dist_description(facts);
        resolve_dist_version(facts);
        resolve_release(facts);
    }

    void lsb_resolver::resolve_dist_id(fact_map& facts)
    {
        string value = execute("lsb_release", {"-i", "-s"});
        if (value.empty()) {
            return;
        }
        facts.add(fact::lsb_dist_id, make_value<string_value>(std::move(value)));
    }

    void lsb_resolver::resolve_dist_release(fact_map& facts)
    {
        string value = execute("lsb_release", {"-r", "-s"});
        if (value.empty()) {
            return;
        }
        facts.add(fact::lsb_dist_release, make_value<string_value>(std::move(value)));
    }

    void lsb_resolver::resolve_dist_codename(fact_map& facts)
    {
        string value = execute("lsb_release", {"-c", "-s"});
        if (value.empty()) {
            return;
        }
        facts.add(fact::lsb_dist_codename, make_value<string_value>(std::move(value)));
    }

    void lsb_resolver::resolve_dist_description(fact_map& facts)
    {
        string value = execute("lsb_release", {"-d", "-s"});
        if (value.empty()) {
            return;
        }

        // The value may be quoted; trim the quotes
        facts.add(fact::lsb_dist_description, make_value<string_value>(std::move(trim(value, { '\"' }))));
    }

    void lsb_resolver::resolve_dist_version(fact_map& facts)
    {
        auto dist_release = facts.get<string_value>(fact::lsb_dist_release);
        if (!dist_release) {
            return;
        }
        string major;
        string minor;
        if (!RE2::PartialMatch(dist_release->value(), "(\\d+)\\.(\\d*)", &major, &minor)) {
            major = dist_release->value();
        }
        facts.add(fact::lsb_dist_major_release, make_value<string_value>(std::move(major)));

        if (!minor.empty()) {
            facts.add(fact::lsb_dist_minor_release, make_value<string_value>(std::move(minor)));
        }
    }

    void lsb_resolver::resolve_release(fact_map& facts)
    {
        string value = execute("lsb_release", {"-v", "-s"});
        if (value.empty()) {
            return;
        }
        facts.add(fact::lsb_release, make_value<string_value>(std::move(value)));
    }

}}}  // namespace cfacter::facts::linux
