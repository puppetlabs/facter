#include <internal/ruby/fact.hpp>
#include <internal/ruby/aggregate_resolution.hpp>
#include <internal/ruby/module.hpp>
#include <internal/ruby/simple_resolution.hpp>
#include <internal/ruby/ruby_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/util/environment.hpp>
#include <leatherman/logging/logging.hpp>
#include <algorithm>

using namespace std;
using namespace facter::facts;
using namespace facter::util;

namespace facter { namespace ruby {

    fact::fact() :
        _resolved(false),
        _resolving(false)
    {
        auto const& ruby = *api::instance();
        _self = ruby.nil_value();
        _name = ruby.nil_value();
        _value = ruby.nil_value();
    }

    VALUE fact::define()
    {
        auto const& ruby = *api::instance();

        VALUE klass = ruby.rb_define_class_under(ruby.lookup({ "Facter", "Util" }), "Fact", *ruby.rb_cObject);
        ruby.rb_define_alloc_func(klass, alloc);
        ruby.rb_define_method(klass, "initialize", RUBY_METHOD_FUNC(ruby_initialize), 1);
        ruby.rb_define_method(klass, "name", RUBY_METHOD_FUNC(ruby_name), 0);
        ruby.rb_define_method(klass, "value", RUBY_METHOD_FUNC(ruby_value), 0);
        ruby.rb_define_method(klass, "resolution", RUBY_METHOD_FUNC(ruby_resolution), 1);
        ruby.rb_define_method(klass, "define_resolution", RUBY_METHOD_FUNC(ruby_define_resolution), -1);
        ruby.rb_define_method(klass, "flush", RUBY_METHOD_FUNC(ruby_flush), 0);
        ruby.rb_obj_freeze(klass);
        return klass;
    }

    VALUE fact::create(VALUE name)
    {
        auto const& ruby = *api::instance();
        return ruby.rb_class_new_instance(1, &name, ruby.lookup({"Facter", "Util", "Fact"}));
    }

    VALUE fact::name() const
    {
        return _name;
    }

    VALUE fact::value()
    {
        auto const& ruby = *api::instance();
        auto facter = module::current();

        collection& facts = facter->facts();

        // Prevent cycles by raising an exception
        if (_resolving) {
            ruby.rb_raise(*ruby.rb_eRuntimeError, "cycle detected while requesting value of fact \"%s\"", ruby.rb_string_value_ptr(&_name));
        }

        if (_resolved) {
            return _value;
        }

        // Sort the resolutions by weight (descending)
        sort(_resolutions.begin(), _resolutions.end(), [&](VALUE first, VALUE second) {
            auto res_first = ruby.to_native<resolution>(first);
            auto res_second = ruby.to_native<resolution>(second);
            return res_first->weight() > res_second->weight();
        });

        _resolving = true;

        // If no resolutions or the top resolution has a weight of 0, first check the native collection for the fact
        // This way we treat the "built-in" as implicitly having a resolution with weight 0
        bool add = true;
        if (_resolutions.empty() || ruby.to_native<resolution>(_resolutions.front())->weight() == 0) {
            // Check to see the value is in the collection
            auto value = facts[ruby.to_string(_name)];
            if (value) {
                // Already in collection, do not add
                add = false;
                _value = ruby.to_ruby(value);
            }
        }

        if (ruby.is_nil(_value)) {
            vector<VALUE>::iterator it;
            ruby.rescue([&]() {
                volatile VALUE value = ruby.nil_value();

                // Look through the resolutions and find the first allowed resolution that resolves
                for (it = _resolutions.begin(); it != _resolutions.end(); ++it) {
                    auto res = ruby.to_native<resolution>(*it);
                    if (!res->suitable(*facter)) {
                        continue;
                    }
                    value = res->value();
                    if (!ruby.is_nil(value)) {
                        break;
                    }
                }

                // Set the value to what was resolved
                _value = value;
                _resolved = true;
                return 0;
            }, [&](VALUE ex) {
                LOG_ERROR("error while resolving custom fact \"%1%\": %2%", ruby.rb_string_value_ptr(&_name), ruby.exception_to_string(ex));

                // Failed, so set to nil
                _value = ruby.nil_value();
                _resolved = true;
                return 0;
            });
        }

        if (add) {
            facts.add(ruby.to_string(_name), ruby.is_nil(_value) ? nullptr : make_value<ruby::ruby_value>(_value));
        }

        _resolving = false;
        return _value;
    }

    void fact::value(VALUE v)
    {
        _value = v;
        _resolved = true;
    }

    VALUE fact::find_resolution(VALUE name) const
    {
        auto const& ruby = *api::instance();

        if (ruby.is_nil(name)) {
            return ruby.nil_value();
        }

        if (!ruby.is_string(name)) {
            ruby.rb_raise(*ruby.rb_eTypeError, "expected resolution name to be a String");
        }

        // Search for the resolution by name
        auto it = find_if(_resolutions.begin(), _resolutions.end(), [&](VALUE self) {
            return ruby.equals(ruby.to_native<resolution>(self)->name(), name);
        });
        if (it == _resolutions.end()) {
            return ruby.nil_value();
        }
        return *it;
    }

    VALUE fact::define_resolution(VALUE name, VALUE options)
    {
        // Do not declare types with destructors; if you do, wrap below in a api::protect call
        auto const& ruby = *api::instance();

        if (!ruby.is_nil(name) && !ruby.is_string(name) && !ruby.is_symbol(name)) {
            ruby.rb_raise(*ruby.rb_eTypeError, "expected resolution name to be a Symbol or String");
        }

        if (ruby.is_symbol(name)) {
            name = ruby.rb_sym_to_s(name);
        }

        bool aggregate = false;
        bool has_weight = false;
        size_t weight = 0;
        volatile VALUE resolution_value = ruby.nil_value();

        // Read the options if provided
        if (!ruby.is_nil(options)) {
            ID simple_id = ruby.rb_intern("simple");
            ID aggregate_id = ruby.rb_intern("aggregate");
            ID type_id = ruby.rb_intern("type");
            ID value_id = ruby.rb_intern("value");
            ID weight_id = ruby.rb_intern("weight");
            ID timeout_id = ruby.rb_intern("timeout");

            if (!ruby.is_hash(options)) {
                ruby.rb_raise(*ruby.rb_eTypeError, "expected a Hash for the options");
            }

            ruby.hash_for_each(options, [&](VALUE key, VALUE value) {
                if (!ruby.is_symbol(key)) {
                    ruby.rb_raise(*ruby.rb_eTypeError, "expected a Symbol for options key");
                }
                ID key_id = ruby.rb_to_id(key);
                if (key_id == type_id) {
                    // Handle the type option
                    if (!ruby.is_symbol(value)) {
                        ruby.rb_raise(*ruby.rb_eTypeError, "expected a Symbol for type option");
                    }
                    ID type_id = ruby.rb_to_id(value);
                    if (type_id != simple_id && type_id != aggregate_id) {
                        ruby.rb_raise(*ruby.rb_eArgError, "expected simple or aggregate for resolution type but was given %s", ruby.rb_id2name(type_id));
                    }
                    aggregate = (type_id == aggregate_id);
                } else if (key_id == value_id) {
                    // Handle the value option
                    resolution_value = value;
                } else if (key_id == weight_id) {
                    // Handle the weight option
                    has_weight = true;
                    weight = static_cast<size_t>(ruby.rb_num2ulong(value));
                } else if (key_id == timeout_id) {
                    // Ignore timeout as it isn't supported
                    static bool timeout_warning = true;
                    if (timeout_warning) {
                        LOG_WARNING("timeout option is not supported for custom facts and will be ignored.")
                        timeout_warning = false;
                    }
                } else {
                    ruby.rb_raise(*ruby.rb_eArgError, "unexpected option %s", ruby.rb_id2name(key_id));
                }
                return true;
            });
        }

        // Find or create the resolution
        VALUE resolution_self = find_resolution(name);
        if (ruby.is_nil(resolution_self)) {
            if (aggregate) {
                _resolutions.push_back(aggregate_resolution::create());
            } else {
                _resolutions.push_back(simple_resolution::create());
            }
            resolution_self = _resolutions.back();
        } else {
            if (aggregate && !ruby.is_a(resolution_self, ruby.lookup({ "Facter", "Core", "Aggregate"}))) {
                ruby.rb_raise(*ruby.rb_eArgError,
                    "cannot define an aggregate resolution with name \"%s\": a simple resolution with the same name already exists",
                    ruby.rb_string_value_ptr(&name));
            } else if (!aggregate && !ruby.is_a(resolution_self, ruby.lookup({ "Facter", "Util", "Resolution"}))) {
                ruby.rb_raise(*ruby.rb_eArgError,
                    "cannot define a simple resolution with name \"%s\": an aggregate resolution with the same name already exists",
                    ruby.rb_string_value_ptr(&name));
            }
        }

        // Set the name, value, and weight
        auto res = ruby.to_native<resolution>(resolution_self);
        res->name(name);
        res->value(resolution_value);
        if (has_weight) {
            res->weight(weight);
        }

        // Call the block if one was given
        if (ruby.rb_block_given_p()) {
            ruby.rb_funcall_passing_block(resolution_self, ruby.rb_intern("instance_eval"), 0, nullptr);
        }
        return resolution_self;
    }

    void fact::flush()
    {
        auto const& ruby = *api::instance();

        // Call flush on every resolution
        for (auto r : _resolutions) {
            ruby.to_native<resolution>(r)->flush();
        }

        // Reset the value
        _resolved = false;
        _value = ruby.nil_value();
    }

    VALUE fact::alloc(VALUE klass)
    {
        auto const& ruby = *api::instance();

        // Create a fact and wrap with a Ruby data object
        unique_ptr<fact> f(new fact());
        VALUE self = f->_self = ruby.rb_data_object_alloc(klass, f.get(), mark, free);
        ruby.register_data_object(self);

        // Release the smart pointer; ownership is now with Ruby's GC
        f.release();
        return self;
    }

    void fact::mark(void* data)
    {
        // Mark all VALUEs contained in the fact
        auto const& ruby = *api::instance();
        auto instance = reinterpret_cast<fact*>(data);

        // Mark the name and value
        ruby.rb_gc_mark(instance->_name);
        ruby.rb_gc_mark(instance->_value);

        // Mark the resolutions
        for (auto v : instance->_resolutions) {
            ruby.rb_gc_mark(v);
        }
    }

    void fact::free(void* data)
    {
        auto instance = reinterpret_cast<fact*>(data);

        // Unregister the data object
        auto const& ruby = *api::instance();
        ruby.unregister_data_object(instance->_self);

        // Delete the fact
        delete instance;
    }

    VALUE fact::ruby_initialize(VALUE self, VALUE name)
    {
        auto const& ruby = *api::instance();

        if (!ruby.is_string(name) && !ruby.is_symbol(name)) {
            ruby.rb_raise(*ruby.rb_eTypeError, "expected a String or Symbol for fact name");
        }

        ruby.to_native<fact>(self)->_name = name;
        return self;
    }

    VALUE fact::ruby_name(VALUE self)
    {
        auto const& ruby = *api::instance();
        return ruby.to_native<fact>(self)->name();
    }

    VALUE fact::ruby_value(VALUE self)
    {
        auto const& ruby = *api::instance();
        return ruby.to_native<fact>(self)->value();
    }

    VALUE fact::ruby_resolution(VALUE self, VALUE name)
    {
        auto const& ruby = *api::instance();
        return ruby.to_native<fact>(self)->find_resolution(name);
    }

    VALUE fact::ruby_define_resolution(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        return ruby.to_native<fact>(self)->define_resolution(argv[0], argc > 1 ? argv[1] : ruby.nil_value());
    }

    VALUE fact::ruby_flush(VALUE self)
    {
        auto const& ruby = *api::instance();
        ruby.to_native<fact>(self)->flush();
        return ruby.nil_value();
    }

}}  // namespace facter::ruby
