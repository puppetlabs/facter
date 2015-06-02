#include <internal/ruby/aggregate_resolution.hpp>
#include <internal/ruby/chunk.hpp>

using namespace std;

namespace facter { namespace ruby {

    aggregate_resolution::aggregate_resolution()
    {
        auto const& ruby = *api::instance();
        _self = ruby.nil_value();
        _block = ruby.nil_value();
    }

    VALUE aggregate_resolution::define()
    {
        auto const& ruby = *api::instance();

        // Define the Resolution class
        VALUE klass = ruby.rb_define_class_under(ruby.lookup({"Facter", "Core"}), "Aggregate", *ruby.rb_cObject);
        ruby.rb_define_alloc_func(klass, alloc);
        ruby.rb_define_method(klass, "chunk", RUBY_METHOD_FUNC(ruby_chunk), -1);
        ruby.rb_define_method(klass, "aggregate", RUBY_METHOD_FUNC(ruby_aggregate), 0);
        resolution::define(klass);
        return klass;
    }

    VALUE aggregate_resolution::create()
    {
        auto const& ruby = *api::instance();
        return ruby.rb_class_new_instance(0, nullptr, ruby.lookup({"Facter", "Core", "Aggregate"}));
    }

    VALUE aggregate_resolution::value()
    {
        auto const& ruby = *api::instance();

        // If given an aggregate block, build a hash and call the block
        if (!ruby.is_nil(_block)) {
            volatile VALUE result = ruby.rb_hash_new();

            for (auto& chunk : _chunks) {
                ruby.rb_hash_aset(
                    result,
                    chunk.first,
                    chunk.second.value(*this));
            }
            return ruby.rb_funcall(_block, ruby.rb_intern("call"), 1, result);
        }

        // Otherwise perform a default aggregation by doing a deep merge
        volatile VALUE merged = ruby.nil_value();
        for (auto& chunk : _chunks) {
            volatile VALUE value = chunk.second.value(*this);
            if (ruby.is_nil(merged)) {
                merged = value;
                continue;
            }
            merged = deep_merge(ruby, merged, value);
        }
        return merged;
    }

    VALUE aggregate_resolution::find_chunk(VALUE name)
    {
        auto const& ruby = *api::instance();

        if (ruby.is_nil(name)) {
            return ruby.nil_value();
        }

        if (!ruby.is_symbol(name)) {
            ruby.rb_raise(*ruby.rb_eTypeError, "expected chunk name to be a Symbol");
        }

        auto it = _chunks.find(name);
        if (it == _chunks.end()) {
            return ruby.nil_value();
        }
        return it->second.value(*this);
    }

    void aggregate_resolution::define_chunk(VALUE name, VALUE options)
    {
        auto const& ruby = *api::instance();

        // A block is required
        if (!ruby.rb_block_given_p()) {
            ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
        }

        if (!ruby.is_symbol(name)) {
            ruby.rb_raise(*ruby.rb_eTypeError, "expected chunk name to be a Symbol");
        }

        volatile VALUE dependencies = ruby.nil_value();
        volatile VALUE block = ruby.rb_block_proc();

        if (!ruby.is_nil(options))
        {
            ID require_id = ruby.rb_intern("require");
            ruby.hash_for_each(options, [&](VALUE key, VALUE value) {
                if (!ruby.is_symbol(key)) {
                    ruby.rb_raise(*ruby.rb_eTypeError, "expected a Symbol for options key");
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

        auto it = _chunks.find(name);
        if (it == _chunks.end()) {
            it = _chunks.emplace(make_pair(name, ruby::chunk(dependencies, block))).first;
        }
        it->second.dependencies(dependencies);
        it->second.block(block);
    }

    VALUE aggregate_resolution::alloc(VALUE klass)
    {
        auto const& ruby = *api::instance();

        // Create a resolution and wrap with a Ruby data object
        unique_ptr<aggregate_resolution> r(new aggregate_resolution());
        VALUE self = r->_self = ruby.rb_data_object_alloc(klass, r.get(), mark, free);
        ruby.register_data_object(self);

        // Release the smart pointer; ownership is now with Ruby's GC
        r.release();
        return self;
    }

    void aggregate_resolution::mark(void* data)
    {
        // Mark all VALUEs contained in the aggregate resolution
        auto const& ruby = *api::instance();
        auto instance = reinterpret_cast<aggregate_resolution*>(data);

        // Mark the base first
        instance->resolution::mark();

        // Mark the aggregate block
        ruby.rb_gc_mark(instance->_block);

        // Mark the chunks
        for (auto& kvp : instance->_chunks) {
            ruby.rb_gc_mark(kvp.first);
            kvp.second.mark();
        }
    }

    void aggregate_resolution::free(void* data)
    {
        auto instance = reinterpret_cast<aggregate_resolution*>(data);

        // Unregister the data object
        auto const& ruby = *api::instance();
        ruby.unregister_data_object(instance->_self);

        // Delete the aggregate resolution
        delete instance;
    }

    VALUE aggregate_resolution::ruby_chunk(int argc, VALUE* argv, VALUE self)
    {
        auto const& ruby = *api::instance();
        if (argc == 0 || argc > 2) {
            ruby.rb_raise(*ruby.rb_eArgError, "wrong number of arguments (%d for 2)", argc);
        }

        ruby.to_native<aggregate_resolution>(self)->define_chunk(argv[0], argc > 1 ? argv[1] : ruby.nil_value());
        return self;
    }

    VALUE aggregate_resolution::ruby_aggregate(VALUE self)
    {
        auto const& ruby = *api::instance();

        // A block is required
        if (!ruby.rb_block_given_p()) {
            ruby.rb_raise(*ruby.rb_eArgError, "a block must be provided");
        }

        ruby.to_native<aggregate_resolution>(self)->_block = ruby.rb_block_proc();
        return self;
    }

    VALUE aggregate_resolution::ruby_merge_hashes(VALUE obj, VALUE context, int argc, VALUE argv[])
    {
        api const* ruby = reinterpret_cast<api const*>(context);
        if (argc != 3) {
            ruby->rb_raise(*ruby->rb_eArgError, "wrong number of arguments (%d for 3)", argc);
        }

        // Recurse on left and right
        return deep_merge(*ruby, argv[1], argv[2]);
    }

    VALUE aggregate_resolution::deep_merge(api const& ruby, VALUE left, VALUE right)
    {
        volatile VALUE result = ruby.nil_value();

        if (ruby.is_hash(left) && ruby.is_hash(right)) {
            result = ruby.rb_block_call(left, ruby.rb_intern("merge"), 1, &right, RUBY_METHOD_FUNC(ruby_merge_hashes), reinterpret_cast<VALUE>(&ruby));
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

}}  // namespace facter::ruby
