/**
 * @file
 * Declares the base class for instantiated Ruby objects.
 */
#ifndef FACTER_RUBY_OBJECT_HPP_
#define FACTER_RUBY_OBJECT_HPP_

#include "api.hpp"
#include <map>

namespace facter { namespace ruby {

    /**
     * Base class for instantiated Ruby objects.
     * @tparam The derived type.
     */
    template <typename T> struct object
    {
        /**
         * Constructs the Ruby object.
         * @param ruby The Ruby API to use.
         */
        explicit object(api const& ruby) :
            _ruby(ruby),
            _self(ruby.nil_value())
        {
            _ruby.rb_gc_register_address(&_self);
        }

        /**
         * Constructs the Ruby object.
         * @param ruby The Ruby API to use.
         * @param self The object's self value.
         */
        object(api const& ruby, VALUE self) :
            _ruby(ruby),
            _self(self)
        {
            _ruby.rb_gc_register_address(&_self);
            associate(_self);
        }

        /**
         * Destructs the Ruby object.
         */
        ~object()
        {
            _ruby.rb_gc_unregister_address(&_self);

            // Remove this instance
            for (auto it = _instances.begin(); it != _instances.end();) {
                if (it->second != this) {
                    ++it;
                    continue;
                }
                _instances.erase(it++);
            }
        }

        /**
         * Prevents the object from being copied.
         */
        explicit object(object<T> const&) = delete;
        /**
         * Prevents the object from being copied.
         * @returns Returns this object.
         */
        object<T>& operator=(object<T> const&) = delete;

        /**
         * Moves the given object into this object.
         * @param other The object to move into this object.
         */
        object(object<T>&& other) :
            _ruby(other._ruby),
            _self(other._self)
        {
            _ruby.rb_gc_register_address(&_self);
            associate(_self);
        }

        /**
         * Moves the given object into this object.
         * @param other The object to move into this object.
         * @return Returns this object.
         */
        object<T>& operator=(object<T>&& other)
        {
            _self = other._self;
            associate(_self);
            return *this;
        }

        /**
         * Gets the corresponding instance from a Ruby self value.
         * @param self The self value to get the instance of.
         * @return Returns the corresponding instance or nullptr if the self is not associated.
         */
        static T* to_instance(VALUE self)
        {
            auto it = _instances.find(self);
            if (it == _instances.end()) {
                return nullptr;
            }
            return it->second;
        }

        /**
         * Returns the self value for this object.
         * @return Returns the object's self value.
         */
        VALUE self() const
        {
            return _self;
        }

     protected:
        /**
         * Associates the given self value with this instance.
         * @param self The self value to associate with this instance.
         */
        void associate(VALUE self)
        {
            _instances[self] = static_cast<T*>(this);
        }

        /**
         * The Ruby API to use.
         */
        api const& _ruby;

        /**
         * This Ruby object's self value.
         */
        VALUE _self;

     private:
        static std::map<VALUE, T*> _instances;
    };

    template<typename T> std::map<VALUE, T*> object<T>::_instances;

    /**
     * External declaration for module.
     */
    extern template struct object<struct module>;
    /**
     * External declaration for fact.
     */
    extern template struct object<struct fact>;
    /**
     * External declaration for resolution.
     */
    extern template struct object<struct resolution>;

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_OBJECT_HPP_
