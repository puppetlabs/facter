#include <facter/ruby/chunk.hpp>
#include <facter/ruby/aggregate_resolution.hpp>

using namespace std;

namespace facter { namespace ruby {

    chunk::chunk(api const& ruby, VALUE dependencies, VALUE block) :
        _ruby(ruby),
        _dependencies(dependencies),
        _block(block),
        _value(ruby.nil_value()),
        _resolved(false),
        _resolving(false)
    {
        _ruby.rb_gc_register_address(&_dependencies);
        _ruby.rb_gc_register_address(&_block);
        _ruby.rb_gc_register_address(&_value);
    }

    chunk::~chunk()
    {
        _ruby.rb_gc_unregister_address(&_dependencies);
        _ruby.rb_gc_unregister_address(&_block);
        _ruby.rb_gc_unregister_address(&_value);
    }

    chunk::chunk(chunk&& other) :
        _ruby(other._ruby),
        _dependencies(other._dependencies),
        _block(other._block),
        _value(other._value),
        _resolved(other._resolved),
        _resolving(other._resolving)
    {
        _ruby.rb_gc_register_address(&_dependencies);
        _ruby.rb_gc_register_address(&_block);
        _ruby.rb_gc_register_address(&_value);
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
        // Prevent cycles by raising an exception
        if (_resolving) {
            _ruby.rb_raise(*_ruby.rb_eRuntimeError, "chunk dependency cycle detected");
        }

        if (_resolved) {
            return _value;
        }

        _resolving = true;

        volatile VALUE value = _ruby.nil_value();
        int tag = 0;
        {
            // Declare all C++ objects here
            vector<VALUE> values;
            string name;

            value = _ruby.protect(tag, [&]{
                // Do not declare any C++ objects inside the protect
                // Their destructors will not be invoked if there is a Ruby exception
                if (_ruby.is_symbol(_dependencies)) {
                    name = _ruby.to_string(_dependencies);
                    values.push_back(resolution.find_chunk(name));
                    _ruby.rb_gc_register_address(&values[0]);
                } else if (_ruby.is_array(_dependencies)) {
                    // Resize the vector now to ensure it is fully allocated before registering with GC
                    values.resize(static_cast<size_t>(_ruby.rb_num2ulong(_ruby.rb_funcall(_dependencies, _ruby.rb_intern("size"), 0))), _ruby.nil_value());
                    for (auto it = values.begin(); it != values.end(); ++it) {
                        _ruby.rb_gc_register_address(&*it);
                    }

                    int i = 0;
                    _ruby.array_for_each(_dependencies, [&](VALUE element) {
                        name = _ruby.to_string(element);
                        values[i++] = resolution.find_chunk(name);
                        return true;
                    });
                }

                // Call the block to get this chunk's value
                return _ruby.rb_funcallv(_block, _ruby.rb_intern("call"), values.size(), values.data());
            });

            // Unregister all the values from the GC
            for (auto it = values.begin(); it != values.end(); ++it) {
                _ruby.rb_gc_unregister_address(&*it);
            }
        }

        _resolving = false;

        if (!tag) {
            _value = value;
            _resolved = true;
            return _value;
        }

        // Now that the above block has exited, it's safe to jump to the given tag
        _ruby.rb_jump_tag(tag);
        return _ruby.nil_value();
    }

    VALUE chunk::dependencies() const
    {
        return _dependencies;
    }

    void chunk::set_dependencies(VALUE dependencies)
    {
        _dependencies = dependencies;
        _value = _ruby.nil_value();
        _resolved = false;
    }

    VALUE chunk::block() const
    {
        return _block;
    }

    void chunk::set_block(VALUE block)
    {
        _block = block;
        _value = _ruby.nil_value();
        _resolved = false;
    }

}}  // namespace facter::ruby
