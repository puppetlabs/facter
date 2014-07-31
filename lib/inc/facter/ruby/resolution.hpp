/**
 * @file
 * Declares the base class for Ruby resolution classes.
 */
#ifndef FACTER_RUBY_RESOLUTION_HPP_
#define FACTER_RUBY_RESOLUTION_HPP_

#include "api.hpp"
#include "object.hpp"
#include "confine.hpp"
#include <vector>
#include <memory>

namespace facter { namespace facts {

    struct value;

}}  // namespace facter::facts

namespace facter { namespace ruby {

    struct module;

    /**
     * The base class for Ruby resolution classes.
     */
    struct resolution : object<resolution>
    {
        /**
         * Constructs a resolution.
         * @param ruby The Ruby API to use.
         * @param self The self value for the resolution.
         */
        resolution(api const& ruby, VALUE self);

        /**
         * Destructs a resolution.
         */
        ~resolution();

        /**
         * Prevents the resolution from being copied.
         */
        resolution(resolution const&) = delete;
        /**
         * Prevents the resolution from being copied.
         * @returns Returns this resolution.
         */
        resolution& operator=(resolution const&) = delete;
        /**
         * Moves the given resolution into this resolution.
         * @param other The resolution to move into this resolution.
         */
        resolution(resolution&& other);
        /**
         * Moves the given resolution into this resolution.
         * @param other The resolution to move into this resolution.
         * @return Returns this resolution.
         */
        resolution& operator=(resolution&& other);

        /**
         * Resolves to a value.
         * @return Returns the resolved value or nil if the fact was not resolved.
         */
        virtual VALUE resolve() = 0;

        /**
         * Gets the name of the resolution.
         * @return Returns the name of the resolution or nil if the resolution has no name.
         */
        VALUE name() const;

        /**
         * Sets the name of the resolution.
         * @param name The name of the resolution.
         */
        void set_name(VALUE name);

        /**
         * Gets the weight of the resolution.
         * The higher the weight value, the more precedence is given to the resolution.
         * @return Returns the weight of the resolution.
         */
        size_t weight() const;

        /** Sets the weight of the resolution.
         * @param weight The weight of the resolution.
         */
        void set_weight(size_t weight);

        /**
         * Gets the value of the resolution or nil if the resolution has no value.
         * @return Returns the value of the resolution or nil if the resolution has no value.
         */
        VALUE value() const;

        /**
         * Sets the value of the resolution.
         * @param value The value of the resolution.
         */
        void set_value(VALUE value);

        /**
         * Determines if the resolution is allowed.
         * @param facter The Ruby facter module to resolve facts with.
         * @returns Returns true if the resolution is allowed or false if it is not.
         */
        bool allowed(module& facter) const;

     protected:
        /**
         * Defines the common resolution methods on the given Ruby class.
         * @param ruby The Ruby API to use.
         * @param klass The Ruby class to define the methods on.
         */
        static void define_methods(api const& ruby, VALUE klass);

     private:
        static VALUE confine_thunk(int argc, VALUE* argv, VALUE self);
        static VALUE has_weight_thunk(VALUE self, VALUE value);
        static VALUE name_thunk(VALUE self);
        static VALUE timeout_thunk(VALUE self, VALUE timeout);

        VALUE _name;
        std::vector<ruby::confine> _confines;
        bool _has_weight;
        size_t _weight;
        VALUE _value;
    };

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_RESOLUTION_HPP_
