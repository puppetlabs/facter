#include <facter/ruby/module.hpp>
#include <facter/ruby/api.hpp>
#include <facter/ruby/aggregate_resolution.hpp>
#include <facter/ruby/simple_resolution.hpp>
#include <facter/ruby/confine.hpp>
#include <facter/facts/collection.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/string.hpp>
#include <facter/execution/execution.hpp>
#include <facter/version.h>
#include <stdexcept>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;

LOG_DECLARE_NAMESPACE("ruby");

namespace facter { namespace ruby {

    template struct object<module>;

    module::module(collection& facts) :
        _collection(facts)
    {
        if (!api::instance()) {
            throw runtime_error("Ruby API is not present.");
        }
        auto const& ruby = *api::instance();
        if (!ruby.initialized()) {
            throw runtime_error("Ruby API is not initialized.");
        }

        // Undefine Facter if it's already defined
        ruby.rb_gc_register_address(&_previous_facter);
        if (ruby.is_true(ruby.rb_const_defined(*ruby.rb_cObject, ruby.rb_intern("Facter")))) {
            _previous_facter = ruby.rb_const_remove(*ruby.rb_cObject, ruby.rb_intern("Facter"));
        } else {
            _previous_facter = ruby.nil_value();
        }

        // Define the Facter module
        self(ruby.rb_define_module("Facter"));
        VALUE facter = self();

        VALUE core = ruby.rb_define_module_under(facter, "Core");
        VALUE execution = ruby.rb_define_module_under(core, "Execution");
        ruby.rb_define_module_under(facter, "Util");

        // Define the methods on the Facter module
        volatile VALUE version = ruby.rb_str_new_cstr(LIBFACTER_VERSION);
        ruby.rb_const_set(facter, ruby.rb_intern("CFACTERVERSION"), version);
        ruby.rb_const_set(facter, ruby.rb_intern("FACTERVERSION"), version);
        ruby.rb_define_singleton_method(facter, "version", RUBY_METHOD_FUNC(ruby_version), 0);
        ruby.rb_define_singleton_method(facter, "add", RUBY_METHOD_FUNC(ruby_add), -1);
        ruby.rb_define_singleton_method(facter, "define_fact", RUBY_METHOD_FUNC(ruby_define_fact), -1);
        ruby.rb_define_singleton_method(facter, "value", RUBY_METHOD_FUNC(ruby_value), 1);
        ruby.rb_define_singleton_method(facter, "[]", RUBY_METHOD_FUNC(ruby_fact), 1);
        ruby.rb_define_singleton_method(facter, "fact", RUBY_METHOD_FUNC(ruby_fact), 1);
        ruby.rb_define_singleton_method(facter, "debug", RUBY_METHOD_FUNC(ruby_debug), 1);
        ruby.rb_define_singleton_method(facter, "debugonce", RUBY_METHOD_FUNC(ruby_debugonce), 1);
        ruby.rb_define_singleton_method(facter, "warn", RUBY_METHOD_FUNC(ruby_warn), 1);
        ruby.rb_define_singleton_method(facter, "warnonce", RUBY_METHOD_FUNC(ruby_warnonce), 1);
        ruby.rb_define_singleton_method(facter, "log_exception", RUBY_METHOD_FUNC(ruby_log_exception), -1);

        // Define the execution module
        ruby.rb_define_singleton_method(execution, "which", RUBY_METHOD_FUNC(ruby_which), 1);
        ruby.rb_define_singleton_method(execution, "exec", RUBY_METHOD_FUNC(ruby_exec), 1);
        ruby.rb_define_singleton_method(execution, "execute", RUBY_METHOD_FUNC(ruby_execute), -1);
        ruby.rb_define_class_under(execution, "ExecutionFailure", *ruby.rb_eStandardError);
        ruby.rb_obj_freeze(execution);

        // Define the Fact and resolution classes
        fact::define();
        simple_resolution::define();
        aggregate_resolution::define();
    }

    module::~module()
    {
        clear_facts();

        auto const& ruby = *api::instance();

        // Undefine the module and restore the previous value
        ruby.rb_const_remove(*ruby.rb_cObject, ruby.rb_intern("Facter"));
        if (!ruby.is_nil(_previous_facter)) {
            ruby.rb_const_set(*ruby.rb_cObject, ruby.rb_intern("Facter"), _previous_facter);
        }

        ruby.rb_gc_unregister_address(&_previous_facter);
    }

    VALUE module::find_fact(VALUE name, bool create)
    {
        auto const& ruby = *api::instance();

        if (!ruby.is_string(name) && !ruby.is_symbol(name)) {
            ruby.rb_raise(*ruby.rb_eTypeError, "expected a String or Symbol for fact name");
        }

        name = normalize(name);

        int tag = 0;
        {
            // Declare all C++ objects here
            string fact_name;
            map<string, VALUE>::iterator it;

            volatile VALUE fact_self = ruby.protect(tag, [&]{
                // Do not declare any C++ objects inside the protect
                // Their destructors will not be invoked if there is a Ruby exception
                fact_name = ruby.to_string(name);

                // Find the fact or create it
                it = _facts.find(fact_name);
                if (it == _facts.end()) {
                    // Check the collection for the fact
                    // If it's in the collection, treat it as found
                    auto value = _collection[fact_name];
                    if (!value && !create) {
                        return ruby.nil_value();
                    }

                    it = _facts.emplace(make_pair(move(fact_name), fact::create(name))).first;
                    ruby.rb_gc_register_address(&it->second);

                    // If it's in the collection, set the fact's value
                    if (value) {
                        fact::from_self(it->second)->value(ruby.to_ruby(value));
                    }
                }
                return it->second;
            });

            if (!tag) {
                return fact_self;
            }
        }

        // Now that the above block has exited, it's safe to jump to the given tag
        ruby.rb_jump_tag(tag);
        return ruby.nil_value();
    }

    VALUE module::fact_value(VALUE name)
    {
        auto const& ruby = *api::instance();

        VALUE fact_self = find_fact(name);
        if (ruby.is_nil(fact_self)) {
            return ruby.nil_value();
        }

        return fact::from_self(fact_self)->value();
    }

    void module::resolve_facts()
    {
        auto const& ruby = *api::instance();

        // Resolve all facts
        for (auto& kvp : _facts) {
            auto f = fact::from_self(kvp.second);

            // If the fact wasn't added, ignore it
            if (!f->added()) {
                continue;
            }

            // Get the fact's value
            volatile VALUE value = f->value();
            if (ruby.is_nil(value)) {
                continue;
            }

            auto fact_value = ruby.to_value(value);
            if (!fact_value) {
                continue;
            }

            // Add it to the collection
            _collection.add(string(kvp.first), move(fact_value));
        }
    }

    void module::clear_facts()
    {
        auto const& ruby = *api::instance();

        for (auto& kvp : _facts) {
            ruby.rb_gc_unregister_address(&kvp.second);
        }

        _facts.clear();
    }

    VALUE module::normalize(VALUE name) const
    {
        auto const& ruby = *api::instance();

        if (ruby.is_symbol(name)) {
            name = ruby.rb_sym_to_s(name);
        }
        if (ruby.is_string(name)) {
            name = ruby.rb_funcall(name, ruby.rb_intern("downcase"), 0);
        }
        return name;
    }

    VALUE module::ruby_version(VALUE self)
    {
        auto const& ruby = *api::instance();
        return ruby.lookup({ "Facter", "FACTERVERSION" });
    }

    VALUE module::ruby_add(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        fact* f = fact::from_self(from_self(self)->find_fact(argv[0], true));

        // Mark the fact as added
        f->added(true);

        // Read the resolution name from the options hash, if present
        VALUE name = ruby.nil_value();
        VALUE options = argc == 2 ? argv[1] : ruby.nil_value();
        if (!ruby.is_nil(options)) {
            name = ruby.rb_funcall(
                    options,
                    ruby.rb_intern("delete"),
                    1,
                    ruby.rb_funcall(ruby.rb_str_new_cstr("name"), ruby.rb_intern("to_sym"), 0));
        }

        int tag = 0;
        ruby.protect(tag, [&]() {
            // Define a resolution
            VALUE resolution_self = f->define_resolution(name, options);

            // Call the block if one was given
            if (ruby.rb_block_given_p()) {
                ruby.rb_funcall_passing_block(resolution_self, ruby.rb_intern("instance_eval"), 0, nullptr);
                return ruby.nil_value();
            }
            return ruby.nil_value();
        });

        // If we've failed, set the value to nil
        if (tag) {
            f->value(ruby.nil_value());
            ruby.rb_jump_tag(tag);
        }
        return self;
    }

    VALUE module::ruby_define_fact(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        fact* f = fact::from_self(from_self(self)->find_fact(argv[0], true));

        // Mark the fact as added
        f->added(true);

        // Call the block if one was given
        if (ruby.rb_block_given_p()) {
            ruby.rb_funcall_passing_block(f->self(), ruby.rb_intern("instance_eval"), 0, nullptr);
        }
        return self;
    }

    VALUE module::ruby_value(VALUE self, VALUE name)
    {
        return from_self(self)->fact_value(name);
    }

    VALUE module::ruby_fact(VALUE self, VALUE name)
    {
        return from_self(self)->find_fact(name);
    }

    VALUE module::ruby_debug(VALUE self, VALUE message)
    {
        auto const& ruby = *api::instance();
        LOG_DEBUG(ruby.to_string(message));
        return self;
    }

    VALUE module::ruby_debugonce(VALUE self, VALUE message)
    {
        auto const& ruby = *api::instance();

        string msg = ruby.to_string(message);
        if (from_self(self)->_debug_messages.insert(msg).second) {
            LOG_DEBUG(msg);
        }
        return self;
    }

    VALUE module::ruby_warn(VALUE self, VALUE message)
    {
        auto const& ruby = *api::instance();
        LOG_WARNING(ruby.to_string(message));
        return self;
    }

    VALUE module::ruby_warnonce(VALUE self, VALUE message)
    {
        auto const& ruby = *api::instance();

        string msg = ruby.to_string(message);
        if (from_self(self)->_warning_messages.insert(msg).second) {
            LOG_WARNING(msg);
        }
        return self;
    }

    VALUE module::ruby_log_exception(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        LOG_ERROR("%1%.\nbacktrace:\n%2%",
            argc == 1 ? ruby.to_string(argv[0]) : ruby.to_string(argv[1]),
            ruby.exception_backtrace(argv[0]));
        return self;
    }

    VALUE module::ruby_which(VALUE self, VALUE binary)
    {
        // Note: self is Facter::Core::Execution
        auto const& ruby = *api::instance();

        string path = execution::which(ruby.to_string(binary));
        if (path.empty()) {
            return ruby.nil_value();
        }

        return ruby.rb_str_new_cstr(path.c_str());
    }

    VALUE module::ruby_exec(VALUE self, VALUE command)
    {
        // Note: self is Facter::Core::Execution
        auto const& ruby = *api::instance();
        return execute_command(ruby.to_string(command), ruby.nil_value(), false);
    }

    VALUE module::ruby_execute(int argc, VALUE* argv, VALUE self)
    {
        // Note: self is Facter::Core::Execution
        auto const& ruby = *api::instance();

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        if (argc == 1) {
            return execute_command(ruby.to_string(argv[0]), ruby.nil_value(), true);
        }

        // Unfortunately we have to call to_sym rather than using ID2SYM, which is Ruby version dependent
        volatile VALUE option = ruby.rb_hash_lookup(argv[1], ruby.rb_funcall(ruby.rb_str_new_cstr("on_fail"), ruby.rb_intern("to_sym"), 0));
        if (ruby.is_symbol(option) && ruby.to_string(option) == "raise") {
            return execute_command(ruby.to_string(argv[0]), ruby.nil_value(), true);
        }
        return execute_command(ruby.to_string(argv[0]), option, false);
    }

    VALUE module::execute_command(std::string const& command, VALUE failure_default, bool raise)
    {
        auto const& ruby = *api::instance();

        // Block to ensure that result is destructed before raising.
        {
            auto result = execution::execute("sh", {"-c", expand_command(command)},
                option_set<execution_options> {
                    execution_options::defaults,
                    execution_options::redirect_stderr
                });
            if (result.first) {
                return ruby.rb_str_new_cstr(result.second.c_str());
            }
        }
        if (raise) {
            ruby.rb_raise(ruby.lookup({ "Facter", "Core", "Execution", "ExecutionFailure"}), "execution of command \"%s\" failed", command.c_str());
        }
        return failure_default;
    }

}}  // namespace facter::ruby
