#include <facter/ruby/module.hpp>
#include <facter/ruby/api.hpp>
#include <facter/ruby/aggregate_resolution.hpp>
#include <facter/ruby/simple_resolution.hpp>
#include <facter/facts/collection.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/string.hpp>
#include <facter/execution/execution.hpp>
#include <facter/version.h>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;

LOG_DECLARE_NAMESPACE("ruby");

namespace facter { namespace ruby {

    template struct object<module>;

    module::module(api const& ruby, collection& facts) :
        object<module>(ruby),
        _collection(facts),
        _old_facter(ruby.nil_value())
    {
        // Undefine Facter if it's already defined
        _ruby.rb_gc_register_address(&_old_facter);
        if (ruby.is_true(ruby.rb_const_defined(*_ruby.rb_cObject, _ruby.rb_intern("Facter")))) {
            _old_facter = _ruby.rb_const_remove(*_ruby.rb_cObject, _ruby.rb_intern("Facter"));
        }

        // Define the Facter modules
        _self = _ruby.rb_define_module("Facter");
        associate(_self);

        VALUE core = _ruby.rb_define_module_under(_self, "Core");
        VALUE execution = _ruby.rb_define_module_under(core, "Execution");
        _ruby.rb_define_module_under(_self, "Util");

        // Define the methods on the Facter module
        volatile VALUE version = _ruby.rb_str_new_cstr(LIBFACTER_VERSION);
        _ruby.rb_const_set(_self, _ruby.rb_intern("CFACTERVERSION"), version);
        _ruby.rb_const_set(_self, _ruby.rb_intern("FACTERVERSION"), version);
        _ruby.rb_define_singleton_method(_self, "version", RUBY_METHOD_FUNC(version_thunk), 0);
        _ruby.rb_define_singleton_method(_self, "add", RUBY_METHOD_FUNC(add_thunk), -1);
        _ruby.rb_define_singleton_method(_self, "define_fact", RUBY_METHOD_FUNC(define_fact_thunk), -1);
        _ruby.rb_define_singleton_method(_self, "value", RUBY_METHOD_FUNC(value_thunk), 1);
        _ruby.rb_define_singleton_method(_self, "[]", RUBY_METHOD_FUNC(fact_thunk), 1);
        _ruby.rb_define_singleton_method(_self, "fact", RUBY_METHOD_FUNC(fact_thunk), 1);
        _ruby.rb_define_singleton_method(_self, "debug", RUBY_METHOD_FUNC(debug_thunk), 1);
        _ruby.rb_define_singleton_method(_self, "debugonce", RUBY_METHOD_FUNC(debug_once_thunk), 1);
        _ruby.rb_define_singleton_method(_self, "warn", RUBY_METHOD_FUNC(warn_thunk), 1);
        _ruby.rb_define_singleton_method(_self, "warnonce", RUBY_METHOD_FUNC(warn_once_thunk), 1);
        _ruby.rb_define_singleton_method(_self, "log_exception", RUBY_METHOD_FUNC(log_exception_thunk), -1);

        // Define the execution module, but associate it with this instance
        _ruby.rb_define_singleton_method(execution, "which", RUBY_METHOD_FUNC(which_thunk), 1);
        _ruby.rb_define_singleton_method(execution, "exec", RUBY_METHOD_FUNC(exec_thunk), 1);
        _ruby.rb_define_singleton_method(execution, "execute", RUBY_METHOD_FUNC(execute_thunk), -1);

        _ruby.rb_define_class_under(execution, "ExecutionFailure", *_ruby.rb_eStandardError);
        ruby.rb_obj_freeze(execution);
        associate(execution);

        // Define the Fact and resolution classes
        fact::define(_ruby);
        simple_resolution::define(_ruby);
        aggregate_resolution::define(_ruby);
    }

    module::~module()
    {
        clear();

        // Undefine the module and restore the previous value
        _ruby.rb_const_remove(*_ruby.rb_cObject, _ruby.rb_intern("Facter"));
        if (!_ruby.is_nil(_old_facter)) {
            _ruby.rb_const_set(*_ruby.rb_cObject, _ruby.rb_intern("Facter"), _old_facter);
        }

        _ruby.rb_gc_unregister_address(&_old_facter);
    }

    VALUE module::find(VALUE name, bool create)
    {
        if (!_ruby.is_string(name) && !_ruby.is_symbol(name)) {
            _ruby.rb_raise(*_ruby.rb_eTypeError, "expected a String or Symbol for first argument");
        }

        name = normalize(name);

        int tag = 0;
        {
            // Declare all C++ objects here
            string fact_name;
            map<string, fact>::iterator it;

            volatile VALUE fact_self = _ruby.protect(tag, [&]{
                // Do not declare any C++ objects inside the protect
                // Their destructors will not be invoked if there is a Ruby exception
                fact_name = _ruby.to_string(name);

                // Find the fact or create it
                it = _facts.find(fact_name);
                if (it == _facts.end()) {
                    // Check the collection for the fact
                    // If it's in the collection, treat it as found
                    auto value = _collection[fact_name];
                    if (!value && !create) {
                        return _ruby.nil_value();
                    }

                    fact f(_ruby, fact_name);

                    // If it's in the collection, set the fact's value
                    if (value) {
                        f.set_value(_ruby.to_ruby(value));
                    }

                    it = _facts.emplace(make_pair(move(fact_name), move(f))).first;
                }
                return it->second.self();
            });

            if (!tag) {
                return fact_self;
            }
        }

        // Now that the above block has exited, it's safe to jump to the given tag
        _ruby.rb_jump_tag(tag);
        return _self;
    }

    VALUE module::value(VALUE name)
    {
        auto f = fact::to_instance(find(name));
        if (!f) {
            return _ruby.nil_value();
        }

        return f->value(*this);
    }

    void module::resolve()
    {
        // Resolve all facts
        for (auto& kvp : _facts) {
            // If the fact wasn't added, ignore it
            if (!kvp.second.added()) {
                continue;
            }

            // Get the fact's value
            volatile VALUE value = kvp.second.value(*this);
            if (_ruby.is_nil(value)) {
                continue;
            }

            auto fact_value = _ruby.to_value(value);
            if (!fact_value) {
                continue;
            }

            // Add it to the collection
            _collection.add(string(kvp.first), move(fact_value));
        }
    }

    void module::clear()
    {
        _facts.clear();
    }

    VALUE module::normalize(VALUE name) const
    {
        if (_ruby.is_symbol(name)) {
            name = _ruby.rb_sym_to_s(name);
        }
        if (_ruby.is_string(name)) {
            name = _ruby.rb_funcall(name, _ruby.rb_intern("downcase"), 0);
        }
        return name;
    }

    VALUE module::version_thunk(VALUE self)
    {
         auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;
        return ruby.lookup({ "Facter", "FACTERVERSION" });
    }

    VALUE module::add_thunk(int argc, VALUE* argv, VALUE self)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        auto f = fact::to_instance(instance->find(argv[0], true));
        if (!f) {
            return ruby.nil_value();
        }

        // Mark the fact as added
        f->set_added();

        // Read the resolution name from the options hash, if present
        VALUE resolution_name = ruby.nil_value();
        VALUE options = argc == 2 ? argv[1] : ruby.nil_value();
        if (!ruby.is_nil(options)) {
            resolution_name = ruby.rb_funcall(
                    options,
                    ruby.rb_intern("delete"),
                    1,
                    ruby.rb_funcall(ruby.rb_str_new_cstr("name"), ruby.rb_intern("to_sym"), 0));
        }

        // Define a resolution
        VALUE resolution_self = f->define_resolution(resolution_name, options);

        // Call the block if one was given
        if (ruby.rb_block_given_p()) {
            int tag = 0;
            ruby.protect(tag, [&]() {
                ruby.rb_funcall_passing_block(resolution_self, ruby.rb_intern("instance_eval"), 0, nullptr);
                return ruby.nil_value();
            });

            // If we've failed, set the value to nil
            if (tag) {
                f->set_value(ruby.nil_value());
                ruby.rb_jump_tag(tag);
            }
        }
        return f->self();
    }

    VALUE module::define_fact_thunk(int argc, VALUE* argv, VALUE self)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        auto f = fact::to_instance(instance->find(argv[0], true));
        if (!f) {
            return ruby.nil_value();
        }

        // Mark the fact as added
        f->set_added();

        // Call the block if one was given
        if (ruby.rb_block_given_p()) {
            ruby.rb_funcall_passing_block(f->self(), ruby.rb_intern("instance_eval"), 0, nullptr);
        }
        return f->self();
    }

    VALUE module::value_thunk(VALUE self, VALUE name)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }
        return instance->value(name);
    }

    VALUE module::fact_thunk(VALUE self, VALUE name)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        auto f = fact::to_instance(instance->find(name));
        if (!f) {
            return ruby.nil_value();
        }
        return f->self();
    }

    VALUE module::debug_thunk(VALUE self, VALUE message)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        LOG_DEBUG(ruby.to_string(message));
        return self;
    }

    VALUE module::debug_once_thunk(VALUE self, VALUE message)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        string msg = ruby.to_string(message);
        if (instance->_debug_messages.insert(msg).second) {
            LOG_DEBUG(msg);
        }
        return self;
    }

    VALUE module::warn_thunk(VALUE self, VALUE message)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        LOG_WARNING(ruby.to_string(message));
        return self;
    }

    VALUE module::warn_once_thunk(VALUE self, VALUE message)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        string msg = ruby.to_string(message);
        if (instance->_warning_messages.insert(msg).second) {
            LOG_WARNING(msg);
        }
        return self;
    }

    VALUE module::log_exception_thunk(int argc, VALUE* argv, VALUE self)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        LOG_ERROR("%1%.\nbacktrace:\n%2%",
            argc == 1 ? ruby.to_string(argv[0]) : ruby.to_string(argv[1]),
            ruby.exception_backtrace(argv[0]));
        return self;
    }

    VALUE module::which_thunk(VALUE self, VALUE binary)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        string path = execution::which(ruby.to_string(binary));
        if (path.empty()) {
            return ruby.nil_value();
        }

        return ruby.rb_str_new_cstr(path.c_str());
    }

    VALUE module::exec_thunk(VALUE self, VALUE command)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        return instance->execute_command(ruby.to_string(command), ruby.nil_value(), false);
    }

    VALUE module::execute_thunk(int argc, VALUE* argv, VALUE self)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        if (argc == 1) {
            return instance->execute_command(ruby.to_string(argv[0]), ruby.nil_value(), true);
        }

        // Unfortunately we have to call to_sym rather than using ID2SYM, which is Ruby version dependent
        volatile VALUE option = ruby.rb_hash_lookup(argv[1], ruby.rb_funcall(ruby.rb_str_new_cstr("on_fail"), ruby.rb_intern("to_sym"), 0));
        if (ruby.is_symbol(option) && ruby.to_string(option) == "raise") {
            return instance->execute_command(ruby.to_string(argv[0]), ruby.nil_value(), true);
        }
        return instance->execute_command(ruby.to_string(argv[0]), option, false);
    }

    VALUE module::execute_command(std::string const& command, VALUE failure_default, bool raise)
    {
        // Block to ensure that result is destructed before raising.
        {
            auto result = execution::execute("sh", {"-c", expand_command(command)},
                option_set<execution_options> {
                    execution_options::defaults,
                    execution_options::redirect_stderr
                });
            if (result.first) {
                return _ruby.rb_str_new_cstr(result.second.c_str());
            }
        }
        if (raise) {
            _ruby.rb_raise(_ruby.lookup({ "Facter", "Core", "Execution", "ExecutionFailure"}), "execution of command \"%s\" failed", command.c_str());
        }
        return failure_default;
    }

}}  // namespace facter::ruby
