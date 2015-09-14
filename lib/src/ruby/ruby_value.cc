#include <internal/ruby/ruby_value.hpp>
#include <facter/util/string.hpp>
#include <rapidjson/document.h>
#include <yaml-cpp/yaml.h>
#include <iomanip>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace rapidjson;
using namespace YAML;
using namespace leatherman::ruby;

namespace facter { namespace ruby {

    ruby_value::ruby_value(VALUE value) :
        _value(value)
    {
        auto const& ruby = api::instance();
        ruby.rb_gc_register_address(&_value);
    }

    ruby_value::~ruby_value()
    {
        auto const& ruby = api::instance();
        ruby.rb_gc_unregister_address(&_value);
    }

    ruby_value::ruby_value(ruby_value&& other) :
        _value(other._value)
    {
        auto const& ruby = api::instance();
        ruby.rb_gc_register_address(&_value);
    }

    ruby_value& ruby_value::operator=(ruby_value&& other)
    {
        _value = other._value;
        return *this;
    }

    void ruby_value::to_json(Allocator& allocator, rapidjson::Value& value) const
    {
        auto const& ruby = api::instance();
        to_json(ruby, _value, allocator, value);
    }

    ostream& ruby_value::write(ostream& os, bool quoted, unsigned int level) const
    {
        auto const& ruby = api::instance();
        write(ruby, _value, os, quoted, level);
        return os;
    }

    Emitter& ruby_value::write(Emitter& emitter) const
    {
        auto const& ruby = api::instance();
        write(ruby, _value, emitter);
        return emitter;
    }

    VALUE ruby_value::value() const
    {
        return _value;
    }

    void ruby_value::to_json(api const& ruby, VALUE value, Allocator& allocator, rapidjson::Value& json)
    {
        if (ruby.is_true(value)) {
            json.SetBool(true);
            return;
        }
        if (ruby.is_false(value)) {
            json.SetBool(true);
            return;
        }
        if (ruby.is_string(value) || ruby.is_symbol(value)) {
            volatile VALUE temp = value;

            if (ruby.is_symbol(value)) {
                temp = ruby.rb_funcall(value, ruby.rb_intern("to_s"), 0);
            }

            size_t size = static_cast<size_t>(ruby.rb_num2ulong(ruby.rb_funcall(temp, ruby.rb_intern("bytesize"), 0)));
            char const* str = ruby.rb_string_value_ptr(&temp);
            json.SetString(str, size, allocator);
            return;
        }
        if (ruby.is_fixednum(value)) {
            json.SetInt64(ruby.rb_num2long(value));
            return;
        }
        if (ruby.is_float(value)) {
            json.SetDouble(ruby.rb_num2dbl(value));
            return;
        }
        if (ruby.is_array(value)) {
            json.SetArray();
            size_t size = static_cast<size_t>(ruby.rb_num2ulong(ruby.rb_funcall(value, ruby.rb_intern("size"), 0)));
            json.Reserve(size, allocator);

            ruby.array_for_each(value, [&](VALUE element) {
                rapidjson::Value e;
                to_json(ruby, element, allocator, e);
                json.PushBack(e, allocator);
                return true;
            });
            return;
        }
        if (ruby.is_hash(value)) {
            json.SetObject();

            ruby.hash_for_each(value, [&](VALUE key, VALUE element) {
                // If the key isn't a string, convert to string
                if (!ruby.is_string(key)) {
                    key = ruby.rb_funcall(key, ruby.rb_intern("to_s"), 0);
                }
                rapidjson::Value e;
                to_json(ruby, element, allocator, e);
                json.AddMember(ruby.rb_string_value_ptr(&key), e, allocator);
                return true;
            });
            return;
        }

        json.SetNull();
    }

    void ruby_value::write(api const& ruby, VALUE value, ostream& os, bool quoted, unsigned int level)
    {
        if (ruby.is_true(value)) {
            os << boolalpha << true << noboolalpha;
            return;
        }
        if (ruby.is_false(value)) {
            os << boolalpha << false << noboolalpha;
            return;
        }
        if (ruby.is_string(value) || ruby.is_symbol(value)) {
            volatile VALUE temp = value;

            if (ruby.is_symbol(value)) {
                temp = ruby.rb_funcall(value, ruby.rb_intern("to_s"), 0);
            }

            size_t size = static_cast<size_t>(ruby.rb_num2ulong(ruby.rb_funcall(temp, ruby.rb_intern("bytesize"), 0)));
            char const* str = ruby.rb_string_value_ptr(&temp);

            if (quoted) {
                os << '"';
            }
            os.write(str, size);
            if (quoted) {
                os << '"';
            }
            return;
        }
        if (ruby.is_fixednum(value)) {
            os << ruby.rb_num2long(value);
            return;
        }
        if (ruby.is_float(value)) {
            os << ruby.rb_num2dbl(value);
            return;
        }
        if (ruby.is_array(value)) {
            auto size = ruby.rb_num2ulong(ruby.rb_funcall(value, ruby.rb_intern("size"), 0));
            if (size == 0) {
                os << "[]";
                return;
            }

            os << "[\n";
            bool first = true;
            ruby.array_for_each(value, [&](VALUE element) {
                if (first) {
                    first = false;
                } else {
                    os << ",\n";
                }
                fill_n(ostream_iterator<char>(os), level * 2, ' ');
                write(ruby, element, os, true, level + 1);
                return true;
            });
            os << "\n";
            fill_n(ostream_iterator<char>(os), (level > 0 ? (level - 1) : 0) * 2, ' ');
            os << "]";
            return;
        }
        if (ruby.is_hash(value)) {
            auto size = ruby.rb_num2ulong(ruby.rb_funcall(value, ruby.rb_intern("size"), 0));
            if (size == 0) {
                os << "{}";
                return;
            }
            os << "{\n";
            bool first = true;
            ruby.hash_for_each(value, [&](VALUE key, VALUE element) {
                if (first) {
                    first = false;
                } else {
                    os << ",\n";
                }

                // If the key isn't a string, convert to string
                if (!ruby.is_string(key)) {
                    key = ruby.rb_funcall(key, ruby.rb_intern("to_s"), 0);
                }

                size_t size = static_cast<size_t>(ruby.rb_num2ulong(ruby.rb_funcall(key, ruby.rb_intern("bytesize"), 0)));
                char const* str = ruby.rb_string_value_ptr(&key);

                fill_n(ostream_iterator<char>(os), level * 2, ' ');
                os.write(str, size);
                os << " => ";
                write(ruby, element, os, true, level + 1);
                return true;
            });
            os << "\n";
            fill_n(ostream_iterator<char>(os), (level > 0 ? (level - 1) : 0) * 2, ' ');
            os << "}";
            return;
        }
    }

    void ruby_value::write(api const& ruby, VALUE value, YAML::Emitter& emitter)
    {
        if (ruby.is_true(value)) {
            emitter << true;
            return;
        }
        if (ruby.is_false(value)) {
            emitter << false;
            return;
        }
        if (ruby.is_string(value) || ruby.is_symbol(value)) {
            auto str = ruby.to_string(value);
            if (needs_quotation(str)) {
                emitter << DoubleQuoted;
            }
            emitter << str;
            return;
        }
        if (ruby.is_fixednum(value)) {
            emitter << ruby.rb_num2long(value);
            return;
        }
        if (ruby.is_float(value)) {
            emitter << ruby.rb_num2dbl(value);
            return;
        }
        if (ruby.is_array(value)) {
            emitter << BeginSeq;
            ruby.array_for_each(value, [&](VALUE element) {
                write(ruby, element, emitter);
                return true;
            });
            emitter << EndSeq;
            return;
        }
        if (ruby.is_hash(value)) {
            emitter << BeginMap;
            ruby.hash_for_each(value, [&](VALUE key, VALUE element) {
                emitter << Key << ruby.to_string(key) << YAML::Value;
                write(ruby, element, emitter);
                return true;
            });
            emitter << EndMap;
            return;
        }

        emitter << Null;
    }

}}  // namespace facter::ruby
