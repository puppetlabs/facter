/**
 * @file
 * Declares the base class for instantiated Ruby objects.
 */
#pragma once

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
         * Destructs the Ruby object.
         */
        ~object()
        {
            _instances.erase(_self);
        }

        /**
         * Gets the C++ object from the Ruby object's self.
         * @param self The Ruby object's self.
         * @return Returns a pointer to the C++ object.
         */
        static T* from_self(VALUE self)
        {
            auto it = _instances.find(self);
            if (it == _instances.end()) {
                auto const& ruby = *api::instance();
                ruby.rb_raise(*ruby.rb_eArgError, "unexpected self value %d", self);
                return nullptr;
            }
            return it->second;
        }

        /**
         * Gets the Ruby object's self.
         * @return Returns the Ruby object's self.
         */
        VALUE self() const
        {
            return _self;
        }

     protected:
        /**
         * Sets the Ruby object's self.
         * @param s The Ruby object's self.
         */
        void self(VALUE s)
        {
            _self = s;
            _instances[_self] = static_cast<T*>(this);
        }

     private:
        static std::map<VALUE, T*> _instances;
        VALUE _self;
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
    /**
     * External declaration for confine.
     */
    extern template struct object<struct confine>;

}}  // namespace facter::ruby
