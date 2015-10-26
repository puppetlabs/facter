#include <facter/ruby/ruby.hpp>
#include <facter/logging/logging.hpp>
#include <internal/ruby/module.hpp>
#include <internal/ruby/ruby_value.hpp>
#include <leatherman/ruby/api.hpp>
#include <leatherman/logging/logging.hpp>

#include <numeric>

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
#ifdef FACTER_RUBY
        api::ruby_lib_location = FACTER_RUBY;
#endif
        try {
            auto& ruby = api::instance();
            ruby.initialize();
            ruby.include_stack_trace(include_stack_trace);
        } catch (runtime_error& ex) {
            LOG_WARNING("%1%: facts requiring Ruby will not be resolved.", ex.what());
            return false;
        }
        return true;
    }

    void load_custom_facts(collection& facts, bool initialize_puppet, vector<string> const& paths)
    {
        api& ruby = api::instance();
        module mod(facts, {}, !initialize_puppet);
        if (initialize_puppet) {
            try {
                ruby.eval(load_puppet);
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

    value const* lookup(value const* value, vector<string>::iterator segment, vector<string>::iterator end) {
        auto rb_value = dynamic_cast<ruby_value const*>(value);
        if (!rb_value) {
             return nullptr;
        }

        // Check for a cached lookup
        auto key = accumulate(segment, end, string{}, [](const string& a, const string& b) -> string {
                 if (b.find(".") != string::npos) {
                     return a+".\""+b+"\"";
                 } else {
                     return a+"."+b;
                 }
             });
        auto child_value = rb_value->child(key);
        if (child_value) {
            return child_value;
        }

        auto val = rb_value->value();  // now we're in ruby land
        api& ruby = api::instance();

        for (; segment != end; ++segment) {
            if (ruby.is_array(val)) {
                long index;
                try {
                    index = stol(*segment);
                } catch (logic_error&) {
                    LOG_DEBUG("cannot lookup an array element with \"%1%\": expected an integral value.", *segment);
                    return nullptr;
                }
                if (index < 0) {
                    LOG_DEBUG("cannot lookup an array element with \"%1%\": expected a non-negative value.", *segment);
                    return nullptr;
                }
                long length = ruby.array_len(val);
                if (0 == length) {
                    LOG_DEBUG("cannot lookup an array element with \"%1%\": the array is empty.", *segment);
                    return nullptr;
                }

                if (index >= length) {
                    LOG_DEBUG("cannot lookup an array element with \"%1%\": expected an integral value between 0 and %2% (inclusive).", *segment, length - 1);
                    return nullptr;
                }

                val = ruby.rb_ary_entry(val, index);
            } else if (ruby.is_hash(val)) {
                // if we're anything but an array, we look up by name
                auto key = ruby.utf8_value(*segment);
                auto result = ruby.rb_hash_lookup(val, key);
                if (ruby.is_nil(result)) {
                    // We also want to try looking up as a symbol
                    key = ruby.to_symbol(*segment);
                    result = ruby.rb_hash_lookup(val, key);
                }
                val = result;
            } else {
                LOG_DEBUG("cannot lookup element \"%1%\": container is not an array or hash", *segment);
            }
            if (ruby.is_nil(val)) {
                return nullptr;
            }
        }
        return rb_value->wrap_child(val, move(key));
    }

    void uninitialize()
    {
        api& ruby = api::instance();
        ruby.uninitialize();
    }
}}  // namespace facter::ruby
