/**
 * @file
 * Declares the Ruby Facter::Util::Fact class.
 */
#pragma once

#include <leatherman/ruby/api.hpp>
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
        static leatherman::ruby::VALUE define();

        /**
         * Creates an instance of the Facter::Util::Fact class.
         * @param name The name of the fact.
         * @return Returns the new instance.
         */
        static leatherman::ruby::VALUE create(leatherman::ruby::VALUE name);

        /**
         * Gets the name of the fact.
         * @return Returns the name of the fact.
         */
        leatherman::ruby::VALUE name() const;

        /**
         * Gets the value of the fact.
         * @return Returns the value of the fact.
         */
        leatherman::ruby::VALUE value();

        /**
         * Sets the value of the fact.
         * @param v The value of the fact.
         */
        void value(leatherman::ruby::VALUE v);

        /**
         * Finds a resolution.
         * @param name The name of the resolution.
         * @return Returns the resolution or nil if the resolution was not found.
         */
        leatherman::ruby::VALUE find_resolution(leatherman::ruby::VALUE name) const;

        /**
         * Defines a resolution.
         * @param name The name of the resolution.
         * @param options The resolution options.
         * @return Returns the resolution instance.
         */
        leatherman::ruby::VALUE define_resolution(leatherman::ruby::VALUE name, leatherman::ruby::VALUE options);

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
        static leatherman::ruby::VALUE alloc(leatherman::ruby::VALUE klass);
        static void mark(void* data);
        static void free(void* data);

        // Methods called from Ruby
        static leatherman::ruby::VALUE ruby_initialize(leatherman::ruby::VALUE self, leatherman::ruby::VALUE name);
        static leatherman::ruby::VALUE ruby_name(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_value(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_resolution(leatherman::ruby::VALUE self, leatherman::ruby::VALUE name);
        static leatherman::ruby::VALUE ruby_define_resolution(int argc, leatherman::ruby::VALUE* argv, leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_flush(leatherman::ruby::VALUE self);

        leatherman::ruby::VALUE _self;
        leatherman::ruby::VALUE _name;
        leatherman::ruby::VALUE _value;
        std::vector<leatherman::ruby::VALUE> _resolutions;
        bool _resolved;
        bool _resolving;
    };

}}  // namespace facter::ruby
