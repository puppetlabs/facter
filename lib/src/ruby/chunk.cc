#include <internal/ruby/chunk.hpp>
#include <internal/ruby/aggregate_resolution.hpp>

using namespace std;
using namespace leatherman::ruby;

namespace facter { namespace ruby {

    chunk::chunk(VALUE dependencies, VALUE block) :
        _dependencies(dependencies),
        _block(block),
        _resolved(false),
        _resolving(false)
    {
        auto const& ruby = api::instance();
        _value = ruby.nil_value();
    }

    chunk::chunk(chunk&& other)
    {
        *this = move(other);
    }

    chunk& chunk::operator=(chunk&& other)
    {
        _dependencies = other._dependencies;
        _block = other._block;
        _value = other._value;
        _resolved = other._resolved;
        _resolving = other._resolving;
        return *this;
    }

    VALUE chunk::value(aggregate_resolution& resolution)
    {
        auto const& ruby = api::instance();

        // Prevent cycles by raising an exception
        if (_resolving) {
            ruby.rb_raise(*ruby.rb_eRuntimeError, "chunk dependency cycle detected");
        }

        if (_resolved) {
            return _value;
        }

        _resolving = true;

        volatile VALUE value = ruby.nil_value();
        int tag = 0;
        {
            // Declare all C++ objects here
            vector<VALUE> values;

            value = ruby.protect(tag, [&]{
                // Do not declare any C++ objects inside the protect
                // Their destructors will not be invoked if there is a Ruby exception
                if (ruby.is_symbol(_dependencies)) {
                    values.push_back(resolution.find_chunk(_dependencies));
                    ruby.rb_gc_register_address(&values[0]);
                } else if (ruby.is_array(_dependencies)) {
                    // Resize the vector now to ensure it is fully allocated before registering with GC
                    values.resize(ruby.num2size_t(ruby.rb_funcall(_dependencies, ruby.rb_intern("size"), 0)), ruby.nil_value());
                    for (auto& v : values) {
                        ruby.rb_gc_register_address(&v);
                    }

                    int i = 0;
                    ruby.array_for_each(_dependencies, [&](VALUE element) {
                        values[i++] = resolution.find_chunk(element);
                        return true;
                    });
                }

                // Call the block to get this chunk's value
                return ruby.rb_funcallv(_block, ruby.rb_intern("call"), values.size(), values.data());
            });

            // Unregister all the values from the GC
            for (auto& v : values) {
                ruby.rb_gc_unregister_address(&v);
            }
        }

        _resolving = false;

        if (!tag) {
            _value = value;
            _resolved = true;
            return _value;
        }

        // Now that the above block has exited, it's safe to jump to the given tag
        ruby.rb_jump_tag(tag);
        return ruby.nil_value();
    }

    VALUE chunk::dependencies() const
    {
        return _dependencies;
    }

    void chunk::dependencies(VALUE dependencies)
    {
        auto const& ruby = api::instance();
        _dependencies = dependencies;
        _value = ruby.nil_value();
        _resolved = false;
    }

    VALUE chunk::block() const
    {
        return _block;
    }

    void chunk::block(VALUE block)
    {
        auto const& ruby = api::instance();
        _block = block;
        _value = ruby.nil_value();
        _resolved = false;
    }

    void chunk::mark() const
    {
        auto const& ruby = api::instance();
        ruby.rb_gc_mark(_dependencies);
        ruby.rb_gc_mark(_block);
        ruby.rb_gc_mark(_value);
    }

}}  // namespace facter::ruby
