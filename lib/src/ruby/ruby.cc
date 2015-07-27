#include <facter/ruby/ruby.hpp>
#include <facter/logging/logging.hpp>
#include <internal/ruby/module.hpp>
#include <leatherman/ruby/api.hpp>

using namespace std;
using namespace facter::facts;
using namespace leatherman::ruby;

static const char load_puppet[] =
"require 'puppet'\n"
"Puppet.initialize_settings\n"
"unless $LOAD_PATH.include?(Puppet[:libdir])\n"
"    $LOAD_PATH << Puppet[:libdir]\n"
"end\n"
"Facter.reset\n"
"Facter.search_external([Puppet[:pluginfactdest]])";

namespace facter { namespace ruby {
    bool initialize(bool include_stack_trace)
    {
        api* ruby = api::instance();
        if (!ruby) {
            return false;
        }
        ruby->initialize();
        ruby->include_stack_trace(include_stack_trace);
        return true;
    }

    void load_custom_facts(collection& facts, bool initialize_puppet, vector<string> const& paths)
    {
        api* ruby = api::instance();
        module mod(facts, {});
        if (initialize_puppet) {
            try {
                ruby->eval(load_puppet);
            } catch (exception& ex) {
                log(facter::logging::level::warning, "Could not load puppet; some facts may be unavailable: %1%", ex.what());
            }
        }
        mod.search(paths);
        mod.resolve_facts();
    }

    void load_custom_facts(collection& facts, vector<string> const& paths)
    {
         load_custom_facts(facts, false, paths);
    }
}}  // namespace facter::ruby
