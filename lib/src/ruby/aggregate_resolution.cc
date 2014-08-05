#include <facter/ruby/aggregate_resolution.hpp>
#include <facter/ruby/chunk.hpp>

using namespace std;

namespace facter { namespace ruby {

    aggregate_resolution::aggregate_resolution(api const& ruby) :
        resolution(ruby, ruby.rb_class_new_instance(0, nullptr, ruby.lookup({ "Facter", "Core", "Aggregate"}))),
        _aggregate(ruby.nil_value())
    {
        _ruby.rb_gc_register_address(&_aggregate);
    }

    aggregate_resolution::~aggregate_resolution()
    {
        _ruby.rb_gc_unregister_address(&_aggregate);
    }

    aggregate_resolution::aggregate_resolution(aggregate_resolution&& other) :
        resolution(other._ruby, other._self),
        _aggregate(other._aggregate),
        _chunks(move(other._chunks))
    {
        _ruby.rb_gc_register_address(&_aggregate);
    }

    aggregate_resolution& aggregate_resolution::operator=(aggregate_resolution&& other)
    {
        // Call the base implementation first
        resolution::operator=(move(other));
        _aggregate = other._aggregate;
        _chunks = move(other._chunks);
        return *this;
    }

    VALUE aggregate_resolution::resolve()
    {
        // If given an aggregate block, build a hash and call the block
        if (!_ruby.is_nil(_aggregate)) {
            volatile VALUE result = _ruby.rb_hash_new();

            for (auto& chunk : _chunks) {
                _ruby.rb_hash_aset(
                    result,
                    _ruby.rb_funcall(_ruby.rb_str_new_cstr(chunk.first.c_str()), _ruby.rb_intern("to_sym"), 0),
                    chunk.second.value(*this));
            }
            return _ruby.rb_funcall(_aggregate, _ruby.rb_intern("call"), 1, result);
        }

        // Otherwise perform a default aggregation by doing a deep merge
        volatile VALUE merged = _ruby.nil_value();
        for (auto& chunk : _chunks) {
            volatile VALUE value = chunk.second.value(*this);
            if (_ruby.is_nil(merged)) {
                merged = value;
                continue;
            }
            merged = deep_merge(_ruby, merged, value);
        }
        return merged;
    }

    VALUE aggregate_resolution::find_chunk(string const& name)
    {
        auto it = _chunks.find(name);
        if (it == _chunks.end()) {
            return _ruby.nil_value();
        }
        return it->second.value(*this);
    }

    VALUE aggregate_resolution::define(api const& ruby)
    {
        // Define the Resolution class
        VALUE klass = ruby.rb_define_class_under(ruby.lookup({"Facter", "Core"}), "Aggregate", *ruby.rb_cObject);
        ruby.rb_define_method(klass, "chunk", RUBY_METHOD_FUNC(chunk_thunk), -1);
        ruby.rb_define_method(klass, "aggregate", RUBY_METHOD_FUNC(aggregate_thunk), 0);
        resolution::define_methods(ruby, klass);
        ruby.rb_obj_freeze(klass);
        return klass;
    }

    VALUE aggregate_resolution::chunk_thunk(int argc, VALUE* argv, VALUE self)
    {
        auto instance = static_cast<aggregate_resolution*>(to_instance(self));
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;
        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        // A block is required
        if (!ruby.rb_block_given_p()) {
            ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
        }

        int tag = 0;
        {
            // Declare all C++ objects here
            string name;
            volatile VALUE block = ruby.nil_value();
            volatile VALUE dependencies = ruby.nil_value();

            ruby.protect(tag, [&]{
                // Do not declare any C++ objects inside the protect
                // Their destructors will not be invoked if there is a Ruby exception

                // Get the name and block
                if (!ruby.is_symbol(argv[0])) {
                    ruby.rb_raise(*ruby.rb_eTypeError, "expected a Symbol for first argument");
                }

                name = ruby.to_string(argv[0]);
                block = ruby.rb_block_proc();

                // Process options
                if (argc == 2) {
                    ID require_id = ruby.rb_intern("require");
                    ruby.hash_for_each(argv[1], [&](VALUE key, VALUE value) {
                        if (!ruby.is_symbol(key)) {
                            ruby.rb_raise(*ruby.rb_eTypeError, "expected a Symbol for Hash key");
                        }
                        ID key_id = ruby.rb_to_id(key);
                        if (key_id == require_id) {
                            if (ruby.is_array((value))) {
                                ruby.array_for_each(value, [&](VALUE element) {
                                    if (!ruby.is_symbol(element)) {
                                        ruby.rb_raise(*ruby.rb_eTypeError, "expected a Symbol or Array of Symbol for require option");
                                    }
                                    return true;
                                });
                            } else if (!ruby.is_symbol(value)) {
                                ruby.rb_raise(*ruby.rb_eTypeError, "expected a Symbol or Array of Symbol for require option");
                            }
                            dependencies = value;
                        } else {
                            ruby.rb_raise(*ruby.rb_eArgError, "unexpected option %s", ruby.rb_id2name(key_id));
                        }
                        return true;
                    });
                }
                return self;
            });

            if (!tag) {
                auto it = instance->_chunks.find(name);
                if (it == instance->_chunks.end()) {
                    it = instance->_chunks.emplace(make_pair(move(name), chunk(ruby, dependencies, block))).first;
                }
                it->second.set_dependencies(dependencies);
                it->second.set_block(block);
                return self;
            }
        }

        // Now that the above block has exited, it's safe to jump to the given tag
        ruby.rb_jump_tag(tag);
        return self;
    }

    VALUE aggregate_resolution::aggregate_thunk(VALUE self)
    {
        auto instance = static_cast<aggregate_resolution*>(to_instance(self));
        if (!instance) {
            return self;
        }

        auto const& ruby = instance->_ruby;

        // A block is required
        if (!ruby.rb_block_given_p()) {
            ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
        }

        instance->_aggregate = ruby.rb_block_proc();
        return self;
    }

    VALUE aggregate_resolution::deep_merge(api const& ruby, VALUE left, VALUE right)
    {
        volatile VALUE result = ruby.nil_value();

        if (ruby.is_hash(left) && ruby.is_hash(right)) {
            result = ruby.rb_funcall_with_block(left, ruby.rb_intern("merge"), 1, &right, ruby.rb_proc_new(RUBY_METHOD_FUNC(merge_hashes), reinterpret_cast<VALUE>(&ruby)));
        } else if (ruby.is_array(left) && ruby.is_array(right)) {
            result = ruby.rb_funcall(left, ruby.rb_intern("+"), 1, right);
        } else if (ruby.is_nil(right)) {
            result = left;
        } else if (ruby.is_nil(left)) {
            result = right;
        } else if (ruby.is_nil(left) && ruby.is_nil(right)) {
            result = ruby.nil_value();
        } else {
            // Let the user know we couldn't merge the chunks
            volatile VALUE inspect_left = ruby.rb_funcall(left, ruby.rb_intern("inspect"), 0);
            volatile VALUE inspect_right = ruby.rb_funcall(right, ruby.rb_intern("inspect"), 0);
            volatile VALUE class_left = ruby.rb_funcall(ruby.rb_funcall(left, ruby.rb_intern("class"), 0), ruby.rb_intern("to_s"), 0);
            volatile VALUE class_right = ruby.rb_funcall(ruby.rb_funcall(right, ruby.rb_intern("class"), 0), ruby.rb_intern("to_s"), 0);
            ruby.rb_raise(*ruby.rb_eRuntimeError, "cannot merge %s:%s and %s:%s",
                    ruby.rb_string_value_ptr(&inspect_left),
                    ruby.rb_string_value_ptr(&class_left),
                    ruby.rb_string_value_ptr(&inspect_right),
                    ruby.rb_string_value_ptr(&class_right));
        }

        return result;
    }

    VALUE aggregate_resolution::merge_hashes(VALUE proc, VALUE proc_value, int argc, VALUE* argv)
    {
        api const* ruby = reinterpret_cast<api const*>(proc_value);
        if (argc != 3) {
            ruby->rb_raise(*ruby->rb_eArgError, "wrong number of arguments (%d for 3)", argc);
        }

        // Recurse on left and right
        return deep_merge(*ruby, argv[1], argv[2]);
    }

}}  // namespace facter::ruby
