/**
 * @file
 * Declares the Ruby Facter::Util::Fact class.
 */
#pragma once

#include "api.hpp"
#include "resolution.hpp"
#include <vector>
#include <memory>

namespace facter { namespace facts {

    struct value;

}}  // namespace facter::facts

namespace facter { namespace ruby {

    struct module;

    /**
     * Represents the Ruby Facter::Util::Fact class.
     */
    struct fact
    {
        /**
         * Defines the Facter::Util::Fact class.
         * @return Returns the Facter::Util::Fact class.
         */
        static VALUE define();

        /**
         * Creates an instance of the Facter::Util::Fact class.
         * @param name The name of the fact.
         * @return Returns the new instance.
         */
        static VALUE create(VALUE name);

        /**
         * Gets the name of the fact.
         * @return Returns the name of the fact.
         */
        VALUE name() const;

        /**
         * Gets the value of the fact.
         * @return Returns the value of the fact.
         */
        VALUE value();

        /**
         * Sets the value of the fact.
         * @param v The value of the fact.
         */
        void value(VALUE v);

        /**
         * Finds a resolution.
         * @param name The name of the resolution.
         * @return Returns the resolution or nil if the resolution was not found.
         */
        VALUE find_resolution(VALUE name) const;

        /**
         * Defines a resolution.
         * @param name The name of the resolution.
         * @param options The resolution options.
         * @return Returns the resolution instance.
         */
        VALUE define_resolution(VALUE name, VALUE options);

        /**
         * Flushes all resolutions for the fact and resets the value.
         */
        void flush();

     private:
        // Construction and assignment
        fact();
        fact(fact const&) = delete;
        fact& operator=(fact const&) = delete;
        fact(fact&& other) = delete;
        fact& operator=(fact&& other) = delete;

        // Ruby lifecycle functions
        static VALUE alloc(VALUE klass);
        static void mark(void* data);
        static void free(void* data);

        // Methods called from Ruby
        static VALUE ruby_initialize(VALUE self, VALUE name);
        static VALUE ruby_name(VALUE self);
        static VALUE ruby_value(VALUE self);
        static VALUE ruby_resolution(VALUE self, VALUE name);
        static VALUE ruby_define_resolution(int argc, VALUE* argv, VALUE self);
        static VALUE ruby_flush(VALUE self);

        VALUE _self;
        VALUE _name;
        VALUE _value;
        std::vector<VALUE> _resolutions;
        bool _resolved;
        bool _resolving;
    };

}}  // namespace facter::ruby
