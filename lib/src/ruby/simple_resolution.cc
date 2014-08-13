#include <facter/ruby/simple_resolution.hpp>
#include <facter/ruby/module.hpp>
#include <facter/facts/value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/execution/execution.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace ruby {

    simple_resolution::simple_resolution(api const& ruby) :
        resolution(ruby, ruby.rb_class_new_instance(0, nullptr, ruby.lookup({ "Facter", "Util", "Resolution"}))),
        _block(ruby.nil_value())
    {
        _ruby.rb_gc_register_address(&_block);
    }

    simple_resolution::~simple_resolution()
    {
        _ruby.rb_gc_unregister_address(&_block);
    }

    simple_resolution::simple_resolution(simple_resolution&& other) :
        resolution(other._ruby, other._self),
        _command(move(other._command)),
        _block(other._block)
    {
        _ruby.rb_gc_register_address(&_block);
    }

    simple_resolution& simple_resolution::operator=(simple_resolution&& other)
    {
        // Call the base implementation first
        resolution::operator=(move(other));
        _command = move(other._command);
        _block = other._block;
        return *this;
    }

    VALUE simple_resolution::resolve()
    {
        // If the resolution has a value, return it
        if (!_ruby.is_nil(value())) {
            return value();
        }

        // If given a block, call it to resolve
        if (!_ruby.is_nil(_block)) {
            return _ruby.rb_funcall(_block, _ruby.rb_intern("call"), 0);
        }

        if (_command.empty()) {
            return _ruby.nil_value();
        }

        // Otherwise, we were given a command so execute it
        auto result = execute("sh", {"-c", expand_command(_command)},
            option_set<execution_options> {
                execution_options::defaults,
                execution_options::redirect_stderr
            });
        if (!result.first) {
            return _ruby.nil_value();
        }
        return _ruby.rb_str_new_cstr(result.second.c_str());
    }

    VALUE simple_resolution::define(api const& ruby)
    {
        // Define the Resolution class
        VALUE klass = ruby.rb_define_class_under(ruby.lookup({"Facter", "Util"}), "Resolution", *ruby.rb_cObject);
        ruby.rb_define_method(klass, "setcode", RUBY_METHOD_FUNC(setcode_thunk), -1);

        // Deprecated in Facter 2.0; implementing for backwards compatibility
        ruby.rb_define_singleton_method(klass, "which", RUBY_METHOD_FUNC(which_thunk), 1);
        ruby.rb_define_singleton_method(klass, "exec", RUBY_METHOD_FUNC(exec_thunk), 1);

        resolution::define_methods(ruby, klass);
        ruby.rb_obj_freeze(klass);
        return klass;
    }

    VALUE simple_resolution::setcode_thunk(int argc, VALUE* argv, VALUE self)
    {
        auto instance = static_cast<simple_resolution*>(to_instance(self));
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        if (argc > 1) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 1)", argc);
        }

        int tag = 0;
        {
            // Declare all C++ objects here
            string command;
            volatile VALUE block = ruby.nil_value();

            ruby.protect(tag, [&]{
                // Do not declare any C++ objects inside the protect
                // Their destructors will not be invoked if there is a Ruby exception
                if (argc == 0) {
                    // No arguments, only a block is required
                    if (!ruby.rb_block_given_p()) {
                        ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
                    }
                    block = ruby.rb_block_proc();
                } else if (argc == 1) {
                    VALUE arg = argv[0];
                    if (!ruby.is_string(arg) || ruby.is_true(ruby.rb_funcall(arg, ruby.rb_intern("empty?"), 0))) {
                        ruby.rb_raise(*ruby.rb_eTypeError, "expected a non-empty String for first argument");
                    }
                    if (ruby.rb_block_given_p()) {
                        ruby.rb_raise(*ruby.rb_eArgError, "a block is unexpected when passing a String");
                    }
                    command = ruby.to_string(arg);
                }
                return self;
            });

            if (!tag) {
                if (!ruby.is_nil(block)) {
                    instance->_block = block;
                    ruby.rb_gc_register_address(&instance->_block);
                } else {
                    instance->_command = move(command);
                }
                return self;
            }
        }

        // Now that the above block has exited, it's safe to jump to the given tag
        ruby.rb_jump_tag(tag);
        return self;
    }

    VALUE simple_resolution::which_thunk(VALUE klass, VALUE binary)
    {
        // As this is a singleton method, we don't have a self to get the instance from; get the api instance instead
        auto ruby = api::instance();
        if (!ruby) {
            return klass;
        }

        return ruby->rb_funcall(ruby->lookup({ "Facter", "Core", "Execution" }), ruby->rb_intern("which"), 1, binary);
    }

    VALUE simple_resolution::exec_thunk(VALUE klass, VALUE command)
    {
        // As this is a singleton method, we don't have a self to get the instance from; get the api instance instead
        auto ruby = api::instance();
        if (!ruby) {
            return klass;
        }

        return ruby->rb_funcall(ruby->lookup({ "Facter", "Core", "Execution" }), ruby->rb_intern("exec"), 1, command);
    }

}}  // namespace facter::ruby
