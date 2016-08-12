#include <internal/ruby/resolution.hpp>
#include <internal/ruby/module.hpp>
#include <leatherman/logging/logging.hpp>

using namespace std;
using namespace facter::facts;
using namespace leatherman::ruby;

namespace facter { namespace ruby {

    resolution::resolution() :
        _has_weight(false),
        _weight(0)
    {
        auto const& ruby = api::instance();
        _name = ruby.nil_value();
        _value = ruby.nil_value();
        _flush_block = ruby.nil_value();
    }

    resolution::~resolution()
    {
    }

    VALUE resolution::name() const
    {
        return _name;
    }

    void resolution::name(VALUE name)
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

    void resolution::weight(size_t weight)
    {
        _has_weight = true;
        _weight = weight;
    }

    VALUE resolution::value()
    {
        return _value;
    }

    void resolution::value(VALUE v)
    {
        _value = v;
    }

    bool resolution::suitable(module& facter) const
    {
        auto const& ruby = api::instance();

        int tag = 0;
        {
            // Declare all C++ objects here
            vector<ruby::confine>::const_iterator it;

            VALUE result = ruby.protect(tag, [&]() {
                // Do not declare any C++ objects inside the protect
                // Their destructors will not be invoked if there is a Ruby exception
                for (it = _confines.begin(); it != _confines.end(); ++it) {
                    if (!it->suitable(facter)) {
                        return ruby.false_value();
                    }
                }
                return ruby.true_value();
            });

            // If all confines were suitable, the resolution is considered to be suitable
            if (!tag) {
                return ruby.is_true(result);
            }
        }

        // Now that the above block has exited, it's safe to jump to the given tag
        ruby.rb_jump_tag(tag);
        return false;
    }

    void resolution::flush() const
    {
        auto const& ruby = api::instance();

        if (ruby.is_nil(_flush_block)) {
            return;
        }

        ruby.rb_funcall(_flush_block, ruby.rb_intern("call"), 0);
    }

    void resolution::confine(VALUE confines)
    {
        auto const& ruby = api::instance();

        if (ruby.is_nil(confines)) {
            // No confines, only a block is required
            if (!ruby.rb_block_given_p()) {
                ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
            }
            _confines.emplace_back(ruby::confine(ruby.nil_value(), ruby.nil_value(), ruby.rb_block_proc()));
        } else {
            if (ruby.is_symbol(confines)) {
                confines = ruby.rb_sym_to_s(confines);
            }
            if (ruby.is_string(confines)) {
                // Argument is a string and a is block required
                if (!ruby.rb_block_given_p()) {
                    ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
                }
                _confines.emplace_back(ruby::confine(confines, ruby.nil_value(), ruby.rb_block_proc()));
            } else if (ruby.is_hash(confines)) {
                // Argument is a hash (block should not be given)
                if (ruby.rb_block_given_p()) {
                    ruby.rb_raise(*ruby.rb_eArgError, "a block is unexpected when passing a Hash");
                }
                ruby.hash_for_each(confines, [&](VALUE key, VALUE value) {
                    if (ruby.is_symbol(key)) {
                        key = ruby.rb_sym_to_s(key);
                    }
                    if (!ruby.is_string(key)) {
                        ruby.rb_raise(*ruby.rb_eTypeError, "expected a String or Symbol for confine key");
                    }
                    if (ruby.is_symbol(value)) {
                        value = ruby.rb_sym_to_s(value);
                    }
                    _confines.emplace_back(ruby::confine(key, value, ruby.nil_value()));
                    return true;
                });
            } else {
                ruby.rb_raise(*ruby.rb_eTypeError, "expected argument to be a String, Symbol, or Hash");
            }
        }
    }

    void resolution::define(VALUE klass)
    {
        auto const& ruby = api::instance();
        ruby.rb_define_method(klass, "confine", RUBY_METHOD_FUNC(ruby_confine), -1);
        ruby.rb_define_method(klass, "has_weight", RUBY_METHOD_FUNC(ruby_has_weight), 1);
        ruby.rb_define_method(klass, "name", RUBY_METHOD_FUNC(ruby_name), 0);
        ruby.rb_define_method(klass, "timeout=", RUBY_METHOD_FUNC(ruby_timeout), 1);
        ruby.rb_define_method(klass, "on_flush", RUBY_METHOD_FUNC(ruby_on_flush), 0);
    }

    void resolution::mark() const
    {
        auto const& ruby = api::instance();

        // Mark the name and value
        ruby.rb_gc_mark(_name);
        ruby.rb_gc_mark(_value);
        ruby.rb_gc_mark(_flush_block);

        // Mark all of the confines
        for (auto const& confine : _confines) {
            confine.mark();
        }
    }

    VALUE resolution::ruby_confine(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = api::instance();

        if (argc > 1) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 1)", argc);
        }

        ruby.to_native<resolution>(self)->confine(argc == 0 ? ruby.nil_value() : argv[0]);
        return self;
    }

    VALUE resolution::ruby_has_weight(VALUE self, VALUE value)
    {
        auto const& ruby = api::instance();

        int64_t val = ruby.rb_num2ll(value);
        if (val < 0) {
            ruby.rb_raise(*ruby.rb_eTypeError, "expected a non-negative value for has_weight (not %lld)", val);
        }

        auto instance = ruby.to_native<resolution>(self);
        instance->_has_weight = true;
        instance->_weight = static_cast<size_t>(val);
        return self;
    }

    VALUE resolution::ruby_name(VALUE self)
    {
        auto const& ruby = api::instance();
        return ruby.to_native<resolution>(self)->name();
    }

    VALUE resolution::ruby_timeout(VALUE self, VALUE timeout)
    {
        static bool timeout_warning = true;
        if (timeout_warning) {
            LOG_WARNING("timeout= is not supported for custom facts and will be ignored.")
            timeout_warning = false;
        }
        // Do nothing as we don't support timeouts
        return self;
    }

    VALUE resolution::ruby_on_flush(VALUE self)
    {
        auto const& ruby = api::instance();

        if (!ruby.rb_block_given_p()) {
            ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
        }

        ruby.to_native<resolution>(self)->_flush_block = ruby.rb_block_proc();
        return self;
    }

}}  // namespace facter::ruby
