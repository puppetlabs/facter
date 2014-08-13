#include <facter/ruby/resolution.hpp>
#include <facter/ruby/module.hpp>
#include <facter/util/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::util;

namespace facter { namespace ruby {

    template struct object<resolution>;

    resolution::resolution(api const& ruby, VALUE self) :
        object<resolution>(ruby, self),
        _name(ruby.nil_value()),
        _has_weight(false),
        _weight(0),
        _value(ruby.nil_value())
    {
        _ruby.rb_gc_register_address(&_name);
        _ruby.rb_gc_register_address(&_value);
    }

    resolution::~resolution()
    {
        _ruby.rb_gc_unregister_address(&_name);
        _ruby.rb_gc_unregister_address(&_value);
    }

    resolution::resolution(resolution&& other) :
        object<resolution>(other._ruby, other._self),
        _name(other._name),
        _confines(move(other._confines)),
        _has_weight(other._has_weight),
        _weight(other._weight),
        _value(other._value)
    {
        _ruby.rb_gc_register_address(&_name);
        _ruby.rb_gc_register_address(&_value);
    }

    resolution& resolution::operator=(resolution&& other)
    {
        object::operator=(move(other));
        _name = other._name;
        _confines = move(other._confines);
        _has_weight = other._has_weight;
        _weight = other._weight;
        _value = other._value;
        return *this;
    }

    VALUE resolution::name() const
    {
        return _name;
    }

    void resolution::set_name(VALUE name)
    {
        _name = name;
    }

    size_t resolution::weight() const
    {
        if (_has_weight) {
            return _weight;
        }
        return _confines.size();
    }

    void resolution::set_weight(size_t weight)
    {
        _has_weight = true;
        _weight = weight;
    }

    VALUE resolution::value() const
    {
        return _value;
    }

    void resolution::set_value(VALUE value)
    {
        _value = value;
    }

    bool resolution::allowed(module& facter) const
    {
        // If any confine is not allowed, the resolution is not allowed
        for (auto const& confine : _confines) {
            if (!confine.allowed(facter)) {
                return false;
            }
        }
        return true;
    }

    void resolution::define_methods(api const& ruby, VALUE klass)
    {
        ruby.rb_define_method(klass, "confine", RUBY_METHOD_FUNC(confine_thunk), -1);
        ruby.rb_define_method(klass, "has_weight", RUBY_METHOD_FUNC(has_weight_thunk), 1);
        ruby.rb_define_method(klass, "name", RUBY_METHOD_FUNC(name_thunk), 0);
        ruby.rb_define_method(klass, "timeout=", RUBY_METHOD_FUNC(timeout_thunk), 1);
    }

    VALUE resolution::confine_thunk(int argc, VALUE* argv, VALUE self)
    {
        auto instance = to_instance(self);
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
            volatile VALUE fact = ruby.nil_value();
            volatile VALUE block = ruby.nil_value();
            map<VALUE, VALUE> confines;

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
                    volatile VALUE arg = argv[0];
                    if (ruby.is_symbol(arg)) {
                        arg = ruby.rb_sym_to_s(arg);
                    }
                    if (ruby.is_string(arg)) {
                        // Argument is a string and a is block required
                        fact = arg;
                        if (!ruby.rb_block_given_p()) {
                            ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
                        }
                        block = ruby.rb_block_proc();
                    } else if (ruby.is_hash(arg)) {
                        // Argument is a hash (block should not be given)
                        if (ruby.rb_block_given_p()) {
                            ruby.rb_raise(*ruby.rb_eArgError, "a block is unexpected when passing a Hash");
                        }
                        // Populate the above map based on the hash's contents
                        ruby.hash_for_each(arg, [&](VALUE key, VALUE value) {
                            if (ruby.is_symbol(key)) {
                                key = ruby.rb_sym_to_s(key);
                            }
                            if (!ruby.is_string(key)) {
                                ruby.rb_raise(*ruby.rb_eTypeError, "expected a String or Symbol for Hash key");
                            }
                            if (ruby.is_symbol(value)) {
                                value = ruby.rb_sym_to_s(value);
                            }
                            if (ruby.is_array(value)) {
                                ruby.array_for_each(value, [&](VALUE value) {
                                    if (!ruby.is_string(value) && !ruby.is_symbol(value)) {
                                        ruby.rb_raise(*ruby.rb_eTypeError, "expected only Symbol or String for array elements");
                                    }
                                    return true;
                                });
                            } else if (!ruby.is_true(value) && !ruby.is_false(value) &&!ruby.is_string(value)) {
                                ruby.rb_raise(*ruby.rb_eTypeError, "expected true, false, Symbol, String, or Array of String/Symbol for Hash value");
                            }

                            // Temporarily register with GC since we may have converted values above that nothing is referencing
                            auto it = confines.insert({ key, value }).first;
                            ruby.rb_gc_register_address(const_cast<VALUE*>(&it->first));
                            ruby.rb_gc_register_address(&it->second);
                            return true;
                        });
                    } else {
                        ruby.rb_raise(*ruby.rb_eTypeError, "expected argument to be a String, Symbol, or Hash");
                    }
                }
                return self;
            });

            // If successful, add the confine(s) to the instance
            if (!tag) {
                if (confines.empty()) {
                    instance->_confines.emplace_back(confine(ruby, fact, ruby.nil_value(), block));
                } else {
                    for (auto& kvp : confines) {
                        instance->_confines.emplace_back(confine(ruby, kvp.first, kvp.second, ruby.nil_value()));
                    }
                }
            }

            // Unregister the confines with the GC
            for (auto it = confines.begin(); it != confines.end(); ++it) {
                ruby.rb_gc_unregister_address(const_cast<VALUE*>(&it->first));
                ruby.rb_gc_unregister_address(&it->second);
            }
        }

        // Now that the above block has exited, it's safe to jump to the given tag
        if (tag) {
            ruby.rb_jump_tag(tag);
        }
        return self;
    }

    VALUE resolution::has_weight_thunk(VALUE self, VALUE value)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        size_t weight = static_cast<size_t>(ruby.rb_num2ulong(value));
        instance->_has_weight = true;
        instance->_weight = weight;
        return self;
    }

    VALUE resolution::name_thunk(VALUE self)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        return instance->name();
    }

    VALUE resolution::timeout_thunk(VALUE self, VALUE timeout)
    {
        // Do nothing as we don't support timeouts
        return self;
    }

}}  // namespace facter::ruby
