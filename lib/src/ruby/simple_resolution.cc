#include <internal/ruby/simple_resolution.hpp>
#include <internal/ruby/module.hpp>
#include <facter/facts/value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/execution/execution.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;

namespace facter { namespace ruby {

    simple_resolution::simple_resolution()
    {
        auto const& ruby = *api::instance();
        _self = ruby.nil_value();
        _block = ruby.nil_value();
        _command = ruby.nil_value();
    }

    VALUE simple_resolution::define()
    {
        auto const& ruby = *api::instance();

        // Define the Resolution class
        VALUE klass = ruby.rb_define_class_under(ruby.lookup({"Facter", "Util"}), "Resolution", *ruby.rb_cObject);
        ruby.rb_define_alloc_func(klass, alloc);
        ruby.rb_define_method(klass, "setcode", RUBY_METHOD_FUNC(ruby_setcode), -1);

        // Deprecated in Facter 2.0; implementing for backwards compatibility
        ruby.rb_define_singleton_method(klass, "which", RUBY_METHOD_FUNC(ruby_which), 1);
        ruby.rb_define_singleton_method(klass, "exec", RUBY_METHOD_FUNC(ruby_exec), 1);

        resolution::define(klass);
        return klass;
    }

    VALUE simple_resolution::create()
    {
        auto const& ruby = *api::instance();
        return ruby.rb_class_new_instance(0, nullptr, ruby.lookup({"Facter", "Util", "Resolution"}));
    }

    VALUE simple_resolution::value()
    {
        auto const& ruby = *api::instance();

        volatile VALUE value = resolution::value();

        // If the resolution has a value, return it
        if (!ruby.is_nil(value)) {
            return value;
        }

        // If given a block, call it to resolve
        if (!ruby.is_nil(_block)) {
            return ruby.rb_funcall(_block, ruby.rb_intern("call"), 0);
        }

        if (ruby.is_nil(_command)) {
            return ruby.nil_value();
        }

        // Otherwise, we were given a command so execute it
        VALUE result = ruby.rb_funcall(ruby.lookup({ "Facter", "Core", "Execution" }), ruby.rb_intern("exec"), 1, _command);
        if (ruby.is_nil(result) || ruby.is_true(ruby.rb_funcall(result, ruby.rb_intern("empty?"), 0))) {
            return ruby.nil_value();
        }
        return result;
    }

    VALUE simple_resolution::alloc(VALUE klass)
    {
        auto const& ruby = *api::instance();

        // Create a resolution and wrap with a Ruby data object
        unique_ptr<simple_resolution> r(new simple_resolution());
        VALUE self = r->_self = ruby.rb_data_object_alloc(klass, r.get(), mark, free);
        ruby.register_data_object(self);

        // Release the smart pointer; ownership is now with Ruby's GC
        r.release();
        return self;
    }

    void simple_resolution::mark(void* data)
    {
        // Mark all VALUEs contained in the simple resolution
        auto const& ruby = *api::instance();
        auto instance = reinterpret_cast<simple_resolution*>(data);

        // Call the base first
        instance->resolution::mark();

        // Mark the setcode block and command
        ruby.rb_gc_mark(instance->_block);
        ruby.rb_gc_mark(instance->_command);
    }

    void simple_resolution::free(void* data)
    {
        auto instance = reinterpret_cast<simple_resolution*>(data);

        // Unregister the data object
        auto const& ruby = *api::instance();
        ruby.unregister_data_object(instance->_self);

        // Delete the simple resolution
        delete instance;
    }

    VALUE simple_resolution::ruby_setcode(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();

        if (argc > 1) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 1)", argc);
        }

        auto instance = ruby.to_native<simple_resolution>(self);

        if (argc == 0) {
            // No arguments, only a block is required
            if (!ruby.rb_block_given_p()) {
                ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
            }
            instance->_block = ruby.rb_block_proc();
        } else if (argc == 1) {
            VALUE arg = argv[0];
            if (!ruby.is_string(arg) || ruby.is_true(ruby.rb_funcall(arg, ruby.rb_intern("empty?"), 0))) {
                ruby.rb_raise(*ruby.rb_eTypeError, "expected a non-empty String for first argument");
            }
            if (ruby.rb_block_given_p()) {
                ruby.rb_raise(*ruby.rb_eArgError, "a block is unexpected when passing a String");
            }
            instance->_command = arg;
        }
        return self;
    }

    VALUE simple_resolution::ruby_which(VALUE klass, VALUE binary)
    {
        auto const& ruby = *api::instance();
        return ruby.rb_funcall(ruby.lookup({ "Facter", "Core", "Execution" }), ruby.rb_intern("which"), 1, binary);
    }

    VALUE simple_resolution::ruby_exec(VALUE klass, VALUE command)
    {
        auto const& ruby = *api::instance();
        return ruby.rb_funcall(ruby.lookup({ "Facter", "Core", "Execution" }), ruby.rb_intern("exec"), 1, command);
    }

}}  // namespace facter::ruby
