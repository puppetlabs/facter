#include <internal/facts/resolvers/ruby_resolver.hpp>
#include <internal/ruby/api.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::ruby;

namespace facter { namespace facts { namespace resolvers {

    ruby_resolver::ruby_resolver() :
        resolver(
            "ruby",
            {
                fact::ruby,
                fact::rubyplatform,
                fact::rubysitedir,
                fact::rubyversion
            })
    {
    }

    static void ruby_fact_rescue(api const& rb, function<VALUE()> cb, string const& label)
    {
        // Use rescue, because Ruby exceptions don't call destructors. The callback cb shouldn't
        // have any object construction/destruction in it.
        rb.rescue(cb, [&](VALUE ex) {
            LOG_ERROR("error while resolving ruby %1% fact: %2%", label, rb.exception_to_string(ex));
            return 0;
        });
    }

    static string get_platform(api const& rb)
    {
        string platform;
        ruby_fact_rescue(rb, [&]() {
            auto val = rb.lookup({"RUBY_PLATFORM"});
            platform = rb.to_string(val);
            return 0;
        }, "platform");
        return platform;
    }

    static string get_sitedir(api const& rb)
    {
        string sitedir;
        ruby_fact_rescue(rb, [&]() {
            rb.rb_require("rbconfig");
            auto config = rb.lookup({"RbConfig", "CONFIG"});
            auto val = rb.rb_hash_lookup(config, rb.utf8_value("sitelibdir"));
            sitedir = rb.to_string(val);
            return 0;
        }, "sitedir");
        return sitedir;
    }

    static string get_version(api const& rb)
    {
        string version;
        ruby_fact_rescue(rb, [&]() {
            auto val = rb.lookup({"RUBY_VERSION"});
            version = rb.to_string(val);
            return 0;
        }, "version");
        return version;
    }

    static void add(collection& f, map_value& d, string s, string hidden, string nested)
    {
        if (!s.empty()) {
            f.add(move(hidden), make_value<string_value>(s, true));
            d.add(move(nested), make_value<string_value>(move(s)));
        }
    }

    ruby_resolver::data ruby_resolver::collect_data(collection& facts)
    {
        data rb_data;

        auto const* ruby = api::instance();
        if (!ruby || !ruby->initialized()) {
            return rb_data;
        }

        rb_data.platform = get_platform(*ruby);
        rb_data.sitedir = get_sitedir(*ruby);
        rb_data.version = get_version(*ruby);

        return rb_data;
    }

    void ruby_resolver::resolve(collection& facts)
    {
        auto rb_data = collect_data(facts);

        auto rb_map = make_value<map_value>();
        add(facts, *rb_map, move(rb_data.platform), fact::rubyplatform, "platform");
        add(facts, *rb_map, move(rb_data.sitedir), fact::rubysitedir, "sitedir");
        add(facts, *rb_map, move(rb_data.version), fact::rubyversion, "version");

        if (!rb_map->empty()) {
            facts.add(fact::ruby, move(rb_map));
        }
    }

}}}  // namespace facter::facts::resolvers
