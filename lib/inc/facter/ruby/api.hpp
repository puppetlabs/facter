/**
 * @file
 * Declares the API imported from Ruby.
 */
#ifndef FACTER_RUBY_API_HPP_
#define FACTER_RUBY_API_HPP_

#include <cstdint>
#include <string>
#include <vector>
#include <functional>
#include <memory>
#include "../util/dynamic_library.hpp"

namespace facter { namespace facts {

    struct value;

}}  // namespace facter::facts

namespace facter {  namespace ruby {

    /**
     * See MRI documentation.
     */
    typedef uintptr_t VALUE;
    /**
     * See MRI documentation.
     */
    typedef intptr_t SIGNED_VALUE;
    /**
     * See MRI documentation.
     */
    typedef uintptr_t ID;

    /**
     * Contains utility functions and the pointers to the Ruby API.
     */
    struct api
    {
        /**
         * Constructs a Ruby API from the given Ruby library.
         * @param library The Ruby library.
         */
        explicit api(facter::util::dynamic_library const& library);

        /**
         * Destructs the Ruby API.
         */
        ~api();

        /**
         * Prevents the API from being copied.
         */
        api(api const&) = delete;
        /**
         * Prevents the API from being copied.
         * @returns Returns this API.
         */
        api& operator=(api const&) = delete;
        /**
         * Prevents the API from being moved.
         */
        api(api&&) = delete;
        /**
         * Prevents the API from being moved.
         * @return Returns this API.
         */
        api& operator=(api&&) = delete;

        /**
         * Finds the Ruby library.
         * @param version The Ruby version for the library name or empty if the default version.
         * @return Returns the loaded Ruby library or an unloaded library if not found.
         */
        static facter::util::dynamic_library load(std::string const& version = {});

        /**
         * Gets the platform-specific Ruby library file name.
         * @param version The requested version.  If empty, the default library name will be returned.
         * @return Returns the platform-specific ruby library file name.
         */
        static std::string get_library_name(std::string const& version = {});

        /**
         * See MRI documentation.
         */
        ID (* const rb_intern)(char const*);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_const_get)(VALUE, ID);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_define_module)(char const*);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_define_class_under)(VALUE, char const*, VALUE super);
        /**
         * See MRI documentation.
         */
        void (* const rb_define_method)(VALUE, char const*, VALUE(*)(...), int);
        /**
         * See MRI documentation.
         */
        void (* const rb_define_singleton_method)(VALUE, char const*, VALUE(*)(...), int);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_class_new_instance)(int, VALUE*, VALUE);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_gv_get)(char const*);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_funcall)(VALUE, ID, int, ...);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_funcall_passing_block)(VALUE, ID, int, VALUE const *);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_num2ulong)(VALUE);
        /**
         * See MRI documentation.
         */
        double (* const rb_num2dbl)(VALUE);
        /**
         * See MRI documentation.
         */
        char const* (* const rb_string_value_ptr)(volatile VALUE*);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_rescue2)(VALUE(*)(...), VALUE, VALUE(*)(...), VALUE, ...);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_protect)(VALUE (*)(VALUE), VALUE, int*);
        /**
         * See MRI documentation.
         */
        void (* const rb_jump_tag)(int);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_int2inum)(SIGNED_VALUE);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_str_new_cstr)(char const*);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_load)(VALUE, int);
        /**
         * See MRI documentation.
         */
        void (* const rb_raise)(VALUE, char const* fmt, ...);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_block_proc)();
        /**
         * See MRI documentation.
         */
        int (* const rb_block_given_p)();
        /**
         * See MRI documentation.
         */
        void (* const rb_gc_register_address)(VALUE*);
        /**
         * See MRI documentation.
         */
        void (* const rb_gc_unregister_address)(VALUE*);
        /**
         * See MRI documentation.
         */
        void (* const rb_hash_foreach)(VALUE, int (*)(...), VALUE);
        /**
         * See MRI documentation.
         */
        void (* const rb_define_attr)(VALUE, char const*, int, int);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_ivar_set)(VALUE, ID, VALUE);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_ivar_get)(VALUE, ID);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_float_new_in_heap)(double);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_ary_new_capa)(long);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_ary_push)(VALUE, VALUE);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_ary_entry)(VALUE, long);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_hash_new)();
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_hash_aset)(VALUE, VALUE, VALUE);

        /**
         * See MRI documentation.
         */
        VALUE* const rb_cObject;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_cArray;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_cHash;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_cString;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_cSymbol;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_cFixnum;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_cFloat;

        /**
         * See MRI documentation.
         */
        VALUE* const rb_eException;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_eArgError;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_eTypeError;

        /**
         * Gets the load path being used by Ruby.
         * @return Returns the load path being used by Ruby.
         */
        std::vector<std::string> get_load_path();

        /**
         * Converts a Ruby value into a C++ string.
         * @param v The Ruby value to convert.
         * @return Returns the Ruby value as a string.
         */
        std::string to_string(VALUE v);

        /**
         * A utility function for wrapping a callback with a rescue clause.
         * @param callback The callback to call in the context of the rescue clause.
         * @param rescue The rescue function to call if there is an exception.
         * @return Returns the VALUE returned from either the callback or the rescue function.
         */
        VALUE rescue(std::function<VALUE()> callback, std::function<VALUE(VALUE)> rescue);

        /**
         * A utility function for wrapping a callback with protection.
         * @param tag The returned jump tag. An exception occurred if the jump tag is non-zero.
         * @param callback The callback to call in the context of protection.
         * @return Returns the VALUE returned from the callback if successful or nil otherwise.
         */
        VALUE protect(int& tag, std::function<VALUE()> callback);

        /**
         * Enumerates an array.
         * @param array The array to enumerate.
         * @param callback The callback to call for every element in the array.
         */
        void array_for_each(VALUE array, std::function<bool(VALUE)> callback);

        /**
         * Enumerates a hash.
         * @param hash The hash to enumerate.
         * @param callback The callback to call for every element in the hash.
         */
        void hash_for_each(VALUE hash, std::function<bool(VALUE, VALUE)> callback);

        /**
         * Gets the given exception's backtrace as a string.
         * @param ex The exception to get the backtrace for.
         * @return Returns the exception's backtrace as a string.
         */
        std::string exception_backtrace(VALUE ex);

        /**
         * Determines if the given value is an instance of the given class (or superclass).
         * @param value The value to check.
         * @param klass The class to check.
         * @return Returns true if the value is an instance of the given class (or a superclass) or false if it is not.
         */
        bool is_a(VALUE value, VALUE klass);
        /**
         * Determines if the given value is nil.
         * @param value The value to check.
         * @return Returns true if the given value is nil or false if it is not.
         */
        bool is_nil(VALUE value);
        /**
         * Determines if the given value is true.
         * @param value The value to check.
         * @return Returns true if the given value is true or false if it is not.
         */
        bool is_true(VALUE value);
        /**
         * Determines if the given value is false.
         * @param value The value to check.
         * @return Returns true if the given value is false or false if it is not.
         */
        bool is_false(VALUE value);
        /**
         * Determines if the given value is a hash.
         * @param value The value to check.
         * @return Returns true if the given value is a hash or false if it is not.
         */
        bool is_hash(VALUE value);
        /**
         * Determines if the given value is an array.
         * @param value The value to check.
         * @return Returns true if the given value is an array or false if it is not.
         */
        bool is_array(VALUE value);
        /**
         * Determines if the given value is a string.
         * @param value The value to check.
         * @return Returns true if the given value is a string or false if it is not.
         */
        bool is_string(VALUE value);
        /**
         * Determines if the given value is a symbol.
         * @param value The value to check.
         * @return Returns true if the given value is a symbol or false if it is not.
         */
        bool is_symbol(VALUE value);
        /**
         * Determines if the given value is a fixed number (Fixnum).
         * @param value The value to check.
         * @return Returns true if the given value is a fixed number (Fixnum) or false if it is not.
         */
        bool is_fixednum(VALUE value);
        /**
         * Determines if the given value is a float.
         * @param value The value to check.
         * @return Returns true if the given value is a float or false if it is not.
         */
        bool is_float(VALUE value);

        /**
         * Gets the VALUE for nil.
         * @return Returns the VALUE for nil.
         */
        VALUE nil_value() const;

        /**
         * Gets the VALUE for true.
         * @return Returns the VALUE for true.
         */
        VALUE true_value() const;

        /**
         * Gets the VALUE for false.
         * @return Returns the VALUE for false.
         */
        VALUE false_value() const;

        /**
         * Converts the given value to a corresponding Ruby object.
         * @param val The value to convert.
         * @return Returns a Ruby object for the value.
         */
        VALUE to_ruby(facter::facts::value const* val);

        /**
         * Converts the given Ruby object to a corresponding value.
         * @param obj The object to convert.
         * @return Returns a pointer to the value or nullptr if nil.
         */
        std::unique_ptr<facter::facts::value> to_value(VALUE obj);

     private:
        // Imported Ruby functions that should not be called externally
        int (* const ruby_setup)();
        void (* const ruby_init)();
        void (* const ruby_options)(int, char**);
        int (* const ruby_cleanup)(volatile int);

        static facter::util::dynamic_library search(std::string const& name, std::vector<std::string> const& directories);
        static VALUE callback_thunk(VALUE parameter);
        static VALUE rescue_thunk(VALUE parameter, VALUE exception);
        static VALUE protect_thunk(VALUE parameter);
        static int hash_for_each_thunk(VALUE key, VALUE value, VALUE arg);

        facter::util::dynamic_library _library;
        VALUE _nil;
        VALUE _true;
        VALUE _false;
        bool _cleanup;
    };

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_API_HPP_
