#include <facter/ruby/ruby.hpp>
#include <internal/ruby/api.hpp>
#include <internal/ruby/module.hpp>

using namespace std;
using namespace facter::facts;

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

    void load_custom_facts(collection& facts, vector<string> const& paths)
    {
        module mod(facts, paths);
        mod.resolve_facts();
    }

}}  // namespace facter::ruby
