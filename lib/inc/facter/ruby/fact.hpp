/**
 * @file
 * Declares the Ruby Fact class.
 */
#ifndef FACTER_RUBY_FACT_HPP_
#define FACTER_RUBY_FACT_HPP_

#include "api.hpp"
#include "object.hpp"
#include "resolution.hpp"
#include <vector>
#include <memory>

namespace facter { namespace facts {

    struct value;

}}  // namespace facter::facts

namespace facter { namespace ruby {

    struct module;

    /**
     * Represents a Ruby fact containing resolutions.
     */
    struct fact : object<fact>
    {
        /**
         * Constructs the fact.
         * @param ruby The Ruby API to use.
         * @param name The name of the fact.
         */
        fact(api const& ruby, std::string const& name);

        /**
         * Destructs the fact.
         */
        ~fact();

        /**
         * Prevents the fact from being copied.
         */
        fact(fact const&) = delete;
        /**
         * Prevents the fact from being copied.
         * @returns Returns this fact.
         */
        fact& operator=(fact const&) = delete;
        /**
         * Moves the given fact into this fact.
         * @param other The fact to move into this fact.
         */
        fact(fact&& other);
        /**
         * Moves the given fact into this fact.
         * @param other The fact to move into this fact.
         * @return Returns this fact.
         */
        fact& operator=(fact&& other);

        /**
         * Defines the Ruby Fact class.
         * @param ruby the Ruby API to use.
         * @return Returns the Ruby class that defines the fact.
         */
        static VALUE define(api const& ruby);

        /**
         * Finds the resolution by name.
         * @param name The name of the resolution.
         * @return Returns the resolution's self or nil if no such resolution exists.
         */
        VALUE find_resolution(VALUE name);

        /**
         * Defines a resolution.
         * @param name The name of the resolution to define.
         * @param options The options for defining the resolution.
         * @return Returns the resolution's self.
         */
        VALUE define_resolution(VALUE name, VALUE options);

        /**
         * Gets the value of the fact.
         * @param facter The Facter module to resolve the fact with.
         * @return Returns the fact's value or nil if the fact did not resolve.
         */
        VALUE value(module& facter);

        /**
         * Sets the fact's value.
         * @param value The value of the fact.
         */
        void set_value(VALUE value);

        /**
         * Determines if the fact was added as part of the Ruby API or internally.
         * @return Returns true if the fact was added as part of the Ruby API or false if it was internally added.
         */
        bool added() const;

        /**
         * Marks the fact as being added through the Ruby API.
         */
        void set_added();

     private:
        static VALUE value_thunk(VALUE self);
        static VALUE resolution_thunk(VALUE self, VALUE name);
        static VALUE define_resolution_thunk(int argc, VALUE* argv, VALUE self);

        std::vector<std::unique_ptr<resolution>> _resolutions;
        VALUE _value;
        bool _resolved;
        bool _resolving;
        bool _added;
    };

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_FACT_HPP_
