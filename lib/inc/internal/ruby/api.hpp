/**
 * @file
 * Declares the API imported from Ruby.
 */
#pragma once

#include <cstdint>
#include <string>
#include <vector>
#include <set>
#include <functional>
#include <memory>
#include <initializer_list>
#include "../util/dynamic_library.hpp"

namespace facter { namespace facts {

    struct value;

}}  // namespace facter::facts

namespace facter {  namespace ruby {

    /*
     * Parts of the MRI (Matz's Ruby Interpreter; a.k.a. CRuby) we use is documented here:
     * https://github.com/ruby/ruby/blob/trunk/README.EXT
     *
     * Otherwise, the canonical documentation is unfortunately the MRI source code itself.
     * A useful index of the various MRI versions can be found here:
     * http://rxr.whitequark.org/mri/source
     *
     */

    /**
     * Represents a MRI VALUE (a Ruby object).
     * VALUEs can be constants denoting things like true, false, or nil.
     * They can also be encoded numerical values (Fixnum, for example).
     * They can also be pointers to a heap-allocated Ruby object (class, module, etc).
     * The Ruby garbage collector scans the main thread's stack for VALUEs to mark during garbage collection.
     * Therefore, you may encounter "volatile" VALUES. These are marked simply to ensure the compiler
     * does not do any optimizations that may prevent the garbage collector from finding them.
     * This is likely not needed, but it isn't hurting us to do.
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
     * See MRI documentation. This is a complex struct type; we only use it as an opaque object.
     */
    typedef void * rb_encoding_p;

    /**
     * Macro to cast function pointers to a Ruby method.
     */
    #define RUBY_METHOD_FUNC(x) reinterpret_cast<VALUE(*)(...)>(x)

    /**
     * Contains utility functions and the pointers to the Ruby API.
     */
    struct api
    {
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
         * Gets the Ruby API instance.
         * @return Returns the Ruby API instance or nullptr if the Ruby API is unavailable.
         */
        static api* instance();

        /**
         * Called to initialize the API.
         * This should be done at the same stack frame where code is loaded into the Ruby VM.
         */
        void initialize();

        /**
         * Gets whether or not the API has been initialized.
         * @return Returns true if the API has been initialized or false if it has not been initialized.
         */
        bool initialized() const;

        /**
         * Called to uninitialize the API.
         * Called during destruction, but can also be called earlier to cleanup Ruby, avoiding potential
         * ordering conflicts between unloading the libfacter DLL and libruby DLL.
         */
        void uninitialize();

        /**
         * Gets whether or not exception stack traces are included when formatting exception messages.
         * @return Returns true if stack traces will be included in exception messages or false if they will not be.
         */
        bool include_stack_trace() const;

        /**
         * Sets whether or not exception stack traces are included when formatting exception messages.
         * @param value True if stack traces will be included in exception messages or false if they will not be.
         */
        void include_stack_trace(bool value);

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
        void (* const rb_const_set)(VALUE, ID, VALUE);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_const_remove)(VALUE, ID);
        /**
         * See MRI documentation.
         */
        int (* const rb_const_defined)(VALUE, ID);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_define_module)(char const*);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_define_module_under)(VALUE, char const*);
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
         VALUE (* const rb_eval_string)(char const*);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_funcall)(VALUE, ID, int, ...);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_funcallv)(VALUE, ID, int, VALUE const*);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_proc_new)(VALUE (*)(...), VALUE);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_block_call)(VALUE, ID, int, VALUE*, VALUE(*)(...), VALUE);
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
        VALUE (* const rb_enc_str_new)(char const*, long, rb_encoding_p);
        /**
         * See MRI documentation.
         */
        rb_encoding_p (* const rb_utf8_encoding)(void);
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
        VALUE (* const rb_hash_lookup)(VALUE, VALUE);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_hash_lookup2)(VALUE, VALUE, VALUE);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_sym_to_s)(VALUE);
        /**
         * See MRI documentation.
         */
        ID (* const rb_to_id)(VALUE);
        /**
         * See MRI documentation.
         */
        char const* (* const rb_id2name)(ID);
        /**
         * See MRI documentation.
         */
        void (* const rb_define_alloc_func)(VALUE, VALUE (*)(VALUE));
        /**
         * See MRI documentation.
         */
        typedef void (*RUBY_DATA_FUNC)(void*);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_data_object_alloc)(VALUE, void*, RUBY_DATA_FUNC, RUBY_DATA_FUNC);
        /**
         * See MRI documentation.
         */
        void (* const rb_gc_mark)(VALUE);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_yield_values)(int n, ...);
        /**
         * See MRI documentation.
         */
        VALUE (* const rb_require)(char const*);

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
         * See MRI documentation.
         */
        VALUE* const rb_eStandardError;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_eRuntimeError;
        /**
         * See MRI documentation.
         */
        VALUE* const rb_eLoadError;

        /**
         * Gets the load path being used by Ruby.
         * @return Returns the load path being used by Ruby.
         */
        std::vector<std::string> get_load_path() const;

        /**
         * Converts a Ruby value into a C++ string.
         * @param v The Ruby value to convert.
         * @return Returns the Ruby value as a string.
         */
        std::string to_string(VALUE v) const;

        /**
         * Converts the given string to a Ruby symbol.
         * @param s The string to convert to a symbol.
         * @return Returns the symbol.
         */
        VALUE to_symbol(std::string const& s) const;

        /**
         * Converts a C string to a Ruby UTF-8 encoded string value.
         * @param s The C string.
         * @param len The number of bytes in the C string.
         * @return Returns the string as a UTF-8 encoded Ruby value.
         */
        VALUE utf8_value(char const* s, size_t len) const;

        /**
         * Converts a C string to a Ruby UTF-8 encoded string value.
         * @param s The C string.
         * @return Returns the string as a UTF-8 encoded Ruby value.
         */
        VALUE utf8_value(char const* s) const;

        /**
         * Converts a C++ string to a Ruby UTF-8 encoded string value.
         * @param s The C++ string.
         * @return Returns the string as a UTF-8 encoded Ruby value.
         */
        VALUE utf8_value(std::string const& s) const;

        /**
         * A utility function for wrapping a callback with a rescue clause.
         * @param callback The callback to call in the context of the rescue clause.
         * @param rescue The rescue function to call if there is an exception.
         * @return Returns the VALUE returned from either the callback or the rescue function.
         */
        VALUE rescue(std::function<VALUE()> callback, std::function<VALUE(VALUE)> rescue) const;

        /**
         * A utility function for wrapping a callback with protection.
         * @param tag The returned jump tag. An exception occurred if the jump tag is non-zero.
         * @param callback The callback to call in the context of protection.
         * @return Returns the VALUE returned from the callback if successful or nil otherwise.
         */
        VALUE protect(int& tag, std::function<VALUE()> callback) const;

        /**
         * Enumerates an array.
         * @param array The array to enumerate.
         * @param callback The callback to call for every element in the array.
         */
        void array_for_each(VALUE array, std::function<bool(VALUE)> callback) const;

        /**
         * Enumerates a hash.
         * @param hash The hash to enumerate.
         * @param callback The callback to call for every element in the hash.
         */
        void hash_for_each(VALUE hash, std::function<bool(VALUE, VALUE)> callback) const;

        /**
         * Converts the given exception into a string.
         * @param ex The exception to get the string representation of.
         * @param message The optional message to use instead of the exception's message.
         * @return Returns the string representation of the exception.
         */
        std::string exception_to_string(VALUE ex, std::string const& message = std::string()) const;

        /**
         * Determines if the given value is an instance of the given class (or superclass).
         * @param value The value to check.
         * @param klass The class to check.
         * @return Returns true if the value is an instance of the given class (or a superclass) or false if it is not.
         */
        bool is_a(VALUE value, VALUE klass) const;
        /**
         * Determines if the given value is nil.
         * @param value The value to check.
         * @return Returns true if the given value is nil or false if it is not.
         */
        bool is_nil(VALUE value) const;
        /**
         * Determines if the given value is true.
         * @param value The value to check.
         * @return Returns true if the given value is true or false if it is not.
         */
        bool is_true(VALUE value) const;
        /**
         * Determines if the given value is false.
         * @param value The value to check.
         * @return Returns true if the given value is false or false if it is not.
         */
        bool is_false(VALUE value) const;
        /**
         * Determines if the given value is a hash.
         * @param value The value to check.
         * @return Returns true if the given value is a hash or false if it is not.
         */
        bool is_hash(VALUE value) const;
        /**
         * Determines if the given value is an array.
         * @param value The value to check.
         * @return Returns true if the given value is an array or false if it is not.
         */
        bool is_array(VALUE value) const;
        /**
         * Determines if the given value is a string.
         * @param value The value to check.
         * @return Returns true if the given value is a string or false if it is not.
         */
        bool is_string(VALUE value) const;
        /**
         * Determines if the given value is a symbol.
         * @param value The value to check.
         * @return Returns true if the given value is a symbol or false if it is not.
         */
        bool is_symbol(VALUE value) const;
        /**
         * Determines if the given value is a fixed number (Fixnum).
         * @param value The value to check.
         * @return Returns true if the given value is a fixed number (Fixnum) or false if it is not.
         */
        bool is_fixednum(VALUE value) const;
        /**
         * Determines if the given value is a float.
         * @param value The value to check.
         * @return Returns true if the given value is a float or false if it is not.
         */
        bool is_float(VALUE value) const;

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
        VALUE to_ruby(facter::facts::value const* val) const;

        /**
         * Looks up a constant based on the given names. The individual entries correspond to
         * namespaces, as in {"A", "B", "C"} => A::B::C.
         * @param names The names to lookup.
         * @return Returns the value or raises a NameError.
         */
        VALUE lookup(std::initializer_list<std::string> const& names) const;

        /**
         * Determines if two values are equal.
         * @param first The first value to compare.
         * @param second The second value to compare.
         * @return Returns true if eql? returns true for the first and second values.
         */
        bool equals(VALUE first, VALUE second) const;

        /**
         * Determines if the first value has case equality (===) with the second value.
         * @param first The first value to compare.
         * @param second The second value to compare.
         * @return Returns true if === returns true for the first and second values.
         */
        bool case_equals(VALUE first, VALUE second) const;

        /**
         * Evalutes a string as ruby code.
         * Any exception raised will be propagated as a C++ runtime_error
         * @param code the ruby code to execute
         */
        void eval(const std::string& code);

        /**
         * Gets the underlying native instance from a Ruby data object.
         * The Ruby object must have been allocated with rb_data_object_alloc.
         * @tparam T The underlying native type.
         * @param obj The Ruby data object to get the native instance for.
         * @return Returns a pointer to the underlying native type.
         */
        template <typename T>
        T* to_native(VALUE obj) const
        {
            return reinterpret_cast<T*>(reinterpret_cast<RData*>(obj)->data);
        }

        /**
         * Registers a data object for cleanup when the API is destructed.
         * The object must have been created with rb_data_object_alloc.
         * @param obj The data object to register.
         */
        void register_data_object(VALUE obj) const
        {
            _data_objects.insert(obj);
        }

        /**
         * Unregisters a data object.
         * @param obj The data object to unregister.
         */
        void unregister_data_object(VALUE obj) const
        {
            _data_objects.erase(obj);
        }

     private:
        explicit api(facter::util::dynamic_library library);
        // Imported Ruby functions that should not be called externally
        int (* const ruby_setup)();
        void (* const ruby_init)();
        void* (* const ruby_options)(int, char**);
        int (* const ruby_cleanup)(volatile int);

        static std::unique_ptr<api> create();
        static facter::util::dynamic_library find_library();
        static facter::util::dynamic_library find_loaded_library();
        static std::string libruby_configdir();
        static VALUE callback_thunk(VALUE parameter);
        static VALUE rescue_thunk(VALUE parameter, VALUE exception);
        static VALUE protect_thunk(VALUE parameter);
        static int hash_for_each_thunk(VALUE key, VALUE value, VALUE arg);

        static std::set<VALUE> _data_objects;

        // Represents object data
        // This definition comes from Ruby (unfortunately)
        struct RData
        {
            VALUE flags;
            const VALUE klass;
            void (*dmark)(void*);
            void (*dfree)(void*);
            void *data;
#ifdef __GNUC__
        } __attribute__((aligned(sizeof(VALUE))));
#else
        };
#endif

        facter::util::dynamic_library _library;
        VALUE _nil = 0u;
        VALUE _true = 0u;
        VALUE _false = 0u;
        bool _initialized = false;
        bool _include_stack_trace = false;
    };

}}  // namespace facter::ruby
