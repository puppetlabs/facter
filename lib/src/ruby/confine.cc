#include <facter/ruby/confine.hpp>
#include <facter/ruby/module.hpp>
#include <facter/util/string.hpp>
#include <algorithm>

using namespace std;
using namespace facter::util;

namespace facter { namespace ruby {

    confine::confine(api const& ruby, VALUE fact, VALUE expected, VALUE block) :
        _ruby(ruby),
        _fact(fact),
        _expected(expected),
        _block(block)
    {
        _ruby.rb_gc_register_address(&_fact);
        _ruby.rb_gc_register_address(&_expected);
        _ruby.rb_gc_register_address(&_block);
    }

    confine::~confine()
    {
        _ruby.rb_gc_unregister_address(&_fact);
        _ruby.rb_gc_unregister_address(&_expected);
        _ruby.rb_gc_unregister_address(&_block);
    }

    confine::confine(confine&& other) :
        _ruby(other._ruby),
        _fact(other._fact),
        _expected(other._expected),
        _block(other._block)
    {
        _ruby.rb_gc_register_address(&_fact);
        _ruby.rb_gc_register_address(&_expected);
        _ruby.rb_gc_register_address(&_block);
    }

    confine& confine::operator=(confine&& other)
    {
        _fact = other._fact;
        _expected = other._expected;
        _block = other._block;
        return *this;
    }

    bool confine::allowed(module& facter) const
    {
        // If given a fact, either call the block or check the values
        if (!_ruby.is_nil(_fact)) {
            volatile VALUE value = facter.normalize(facter.value(_fact));
            if (_ruby.is_nil(value)) {
                return false;
            }
            // Pass the value to the block if given one
            if (!_ruby.is_nil(_block)) {
                volatile VALUE result = _ruby.rb_funcall(_block, _ruby.rb_intern("call"), 1, value);
                return !_ruby.is_nil(result) && !_ruby.is_false(result);
            }

            // Otherwise, if it's an array, search for the value
            if (_ruby.is_array(_expected)) {
                bool found = false;
                _ruby.array_for_each(_expected, [&](VALUE expected_value) {
                    expected_value = facter.normalize(expected_value);
                    found = _ruby.equals(facter.normalize(expected_value), value);
                    return !found;
                });
                return found;
            }
            // Compare the value directly
            return _ruby.equals(facter.normalize(_expected), value);
        }
        // If we have only a block, execute it
        if (!_ruby.is_nil(_block)) {
            volatile VALUE result = _ruby.rb_funcall(_block, _ruby.rb_intern("call"), 0);
            return !_ruby.is_nil(result) && !_ruby.is_false(result);
        }
        return false;
    }

}}  // namespace facter::ruby
