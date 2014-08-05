#include <facter/ruby/fact.hpp>
#include <facter/ruby/module.hpp>
#include <facter/ruby/aggregate_resolution.hpp>
#include <facter/ruby/simple_resolution.hpp>
#include <facter/facts/value.hpp>
#include <facter/util/string.hpp>
#include <facter/logging/logging.hpp>
#include <algorithm>

using namespace std;
using namespace facter::facts;
using namespace facter::util;

LOG_DECLARE_NAMESPACE("ruby");

namespace facter { namespace ruby {

    template struct object<fact>;

    fact::fact(api const& ruby, std::string const& name) :
        object<fact>(ruby, ruby.rb_class_new_instance(0, nullptr, ruby.lookup({"Facter", "Util", "Fact"}))),
        _value(ruby.nil_value()),
        _resolved(false),
        _resolving(false),
        _added(false)
    {
        _ruby.rb_gc_register_address(&_value);
        _ruby.rb_ivar_set(_self, ruby.rb_intern("@name"), _ruby.rb_str_new_cstr(name.c_str()));
    }

    fact::~fact()
    {
        _ruby.rb_gc_unregister_address(&_value);
    }

    fact::fact(fact&& other) :
        object<fact>(other._ruby, other._self),
        _resolutions(move(other._resolutions)),
        _value(other._value),
        _resolved(other._resolved),
        _resolving(other._resolving),
        _added(other._added)
    {
        _ruby.rb_gc_register_address(&_value);
    }

    fact& fact::operator=(fact&& other)
    {
        object::operator=(move(other));
        _resolutions = move(other._resolutions);
        _value = other._value;
        _resolved = other._resolved;
        _resolving = other._resolving;
        _added = other._added;
        return *this;
    }

    VALUE fact::define(api const& ruby)
    {
        VALUE klass = ruby.rb_define_class_under(ruby.lookup({ "Facter", "Util" }), "Fact", *ruby.rb_cObject);
        ruby.rb_define_attr(klass, "name", 1, 0);
        ruby.rb_define_method(klass, "value", RUBY_METHOD_FUNC(value_thunk), 0);
        ruby.rb_define_method(klass, "define_resolution", RUBY_METHOD_FUNC(define_resolution_thunk), -1);
        ruby.rb_define_method(klass, "resolution", RUBY_METHOD_FUNC(resolution_thunk), 1);
        ruby.rb_obj_freeze(klass);
        return klass;
    }

    VALUE fact::find_resolution(VALUE name)
    {
        if (_ruby.is_nil(name)) {
            return _ruby.nil_value();
        }

        if (!_ruby.is_string(name)) {
            _ruby.rb_raise(*_ruby.rb_eTypeError, "expected argument to be a String");
        }

        // Search for the resolution by name
        auto it = find_if(_resolutions.begin(), _resolutions.end(), [&](unique_ptr<resolution> const& p) {
            return _ruby.equals(p->name(), name);
        });
        if (it == _resolutions.end()) {
            return _ruby.nil_value();
        }
        return (*it)->self();
    }

    VALUE fact::define_resolution(VALUE name, VALUE options)
    {
        // Do not declare types with destructors; if you do, wrap below in a api::protect call

        if (!_ruby.is_nil(name) && !_ruby.is_string(name) && !_ruby.is_symbol(name)) {
            _ruby.rb_raise(*_ruby.rb_eTypeError, "expected first argument to be a Symbol or String");
        }

        if (_ruby.is_symbol(name)) {
            name = _ruby.rb_sym_to_s(name);
        }

        bool aggregate = false;
        bool has_weight = false;
        size_t weight = 0;
        volatile VALUE resolution_value = _ruby.nil_value();

        // Read the options if provided
        if (!_ruby.is_nil(options)) {
            ID simple_id = _ruby.rb_intern("simple");
            ID aggregate_id = _ruby.rb_intern("aggregate");
            ID type_id = _ruby.rb_intern("type");
            ID value_id = _ruby.rb_intern("value");
            ID weight_id = _ruby.rb_intern("weight");
            ID timeout_id = _ruby.rb_intern("timeout");

            if (!_ruby.is_hash(options)) {
                _ruby.rb_raise(*_ruby.rb_eTypeError, "expected a Hash for the options");
            }

            _ruby.hash_for_each(options, [&](VALUE key, VALUE value) {
                if (!_ruby.is_symbol(key)) {
                    _ruby.rb_raise(*_ruby.rb_eTypeError, "expected a Symbol for Hash key");
                }
                ID key_id = _ruby.rb_to_id(key);
                if (key_id == type_id) {
                    // Handle the type option
                    if (!_ruby.is_symbol(value)) {
                        _ruby.rb_raise(*_ruby.rb_eTypeError, "expected a Symbol for type option");
                    }
                    ID type_id = _ruby.rb_to_id(value);
                    if (type_id != simple_id && type_id != aggregate_id) {
                        _ruby.rb_raise(*_ruby.rb_eArgError, "expected simple or aggregate for resolution type but was given %s", _ruby.rb_id2name(type_id));
                    }
                    aggregate = (type_id == aggregate_id);
                } else if (key_id == value_id) {
                    // Handle the value option
                    resolution_value = value;
                } else if (key_id == weight_id) {
                    // Handle the weight option
                    has_weight = true;
                    weight = static_cast<size_t>(_ruby.rb_num2ulong(value));
                } else if (key_id == timeout_id) {
                    // Ignore timeout as it isn't supported
                } else {
                    _ruby.rb_raise(*_ruby.rb_eArgError, "unexpected option %s", _ruby.rb_id2name(key_id));
                }
                return true;
            });
        }

        // Find or create the resolution
        auto res = resolution::to_instance(find_resolution(name));
        if (!res) {
            if (aggregate) {
                _resolutions.emplace_back(unique_ptr<resolution>(new aggregate_resolution(_ruby)));
            } else {
                _resolutions.emplace_back(unique_ptr<resolution>(new simple_resolution(_ruby)));
            }
            res = _resolutions.back().get();
        } else {
            if (aggregate && !dynamic_cast<aggregate_resolution*>(res)) {
                _ruby.rb_raise(*_ruby.rb_eArgError,
                    "cannot define an aggregate resolution with name \"%s\": a simple resolution with the same name already exists",
                    _ruby.rb_string_value_ptr(&name));
            } else if (!aggregate && !dynamic_cast<simple_resolution*>(res)) {
                _ruby.rb_raise(*_ruby.rb_eArgError,
                    "cannot define a simple resolution with name \"%s\": an aggregate resolution with the same name already exists",
                    _ruby.rb_string_value_ptr(&name));
            }
        }

        if (res) {
            // Set the name, value, and weight
            res->set_name(name);
            res->set_value(resolution_value);
            if (has_weight) {
                res->set_weight(weight);
            }
            return res->self();
        }
        return _ruby.nil_value();
    }

    VALUE fact::value(module& facter)
    {
        // Prevent cycles by raising an exception
        if (_resolving) {
            VALUE name = _ruby.rb_ivar_get(_self, _ruby.rb_intern("@name"));
            _ruby.rb_raise(*_ruby.rb_eRuntimeError, "cycle detected while requesting value of fact \"%s\"", _ruby.rb_string_value_ptr(&name));
        }

        if (_resolved) {
            return _value;
        }

        // Sort the resolutions by weight (descending)
        sort(_resolutions.begin(), _resolutions.end(), [](unique_ptr<resolution> const& first, unique_ptr<resolution> const& second) {
            return first->weight() > second->weight();
        });

        vector<unique_ptr<resolution>>::iterator it;

        _resolving = true;
        _ruby.rescue([&]() {
            volatile VALUE value = _ruby.nil_value();
            // Look through the resolutions and find the first allowed resolution that resolves
            for (it = _resolutions.begin(); it != _resolutions.end(); ++it) {
                if (!(*it)->allowed(facter)) {
                    continue;
                }
                value = (*it)->resolve();
                if (!_ruby.is_nil(value)) {
                    break;
                }
            }
            set_value(value);
            return 0;
        }, [&](VALUE ex) {
            VALUE name = _ruby.rb_ivar_get(_self, _ruby.rb_intern("@name"));
            LOG_ERROR("error while resolving custom fact \"%1%\": %2%.\nbacktrace:\n%3%",
                _ruby.rb_string_value_ptr(&name),
                _ruby.to_string(ex),
                _ruby.exception_backtrace(ex));
            set_value(_ruby.nil_value());
            return 0;
        });
        _resolving = false;
        return _value;
    }

    void fact::set_value(VALUE value)
    {
        _resolved = true;
        _value = value;
    }

    bool fact::added() const
    {
        return _added;
    }

    void fact::set_added()
    {
        _added = true;

        // Adding a fact clears whether or not it's been resolved
        _resolved = false;
        _value = _ruby.nil_value();
    }

    VALUE fact::value_thunk(VALUE self)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        auto mod = module::to_instance(ruby.lookup({"Facter"}));
        if (!mod) {
            ruby.rb_raise(*ruby.rb_eArgError, "cannot find Facter module");
        }
        return instance->value(*mod);
    }

    VALUE fact::define_resolution_thunk(int argc, VALUE* argv, VALUE self)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        VALUE resolution = instance->define_resolution(argv[0], argc == 2 ? argv[1] : ruby.nil_value());

        // Call the block if one was given
        if (ruby.rb_block_given_p()) {
            ruby.rb_funcall_passing_block(resolution, ruby.rb_intern("instance_eval"), 0, nullptr);
        }
        return resolution;
    }

    VALUE fact::resolution_thunk(VALUE self, VALUE name)
    {
        auto instance = to_instance(self);
        if (!instance) {
            return self;
        }
        return instance->find_resolution(name);
    }

}}  // namespace facter::ruby
