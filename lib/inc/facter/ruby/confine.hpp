/**
 * @file
 * Declares the class for Ruby fact confines.
 */
#ifndef FACTER_RUBY_CONFINE_HPP_
#define FACTER_RUBY_CONFINE_HPP_

#include "api.hpp"
#include <string>
#include <vector>

namespace facter { namespace ruby {

    struct module;

    /**
     * Represents a Ruby API confine.
     */
    struct confine
    {
        /**
         * Confines a fact resolution based on a fact name and vector of expected values.
         * @param ruby The Ruby API to use.
         * @param fact The fact name to confine to.  Can be nil if a block is given.
         * @param expected The expected value or values for the given fact.  Can be nil if no fact given.
         * @param block The block to call for the confine.  Can be nil.
         */
        confine(api const& ruby, VALUE fact, VALUE expected, VALUE block);

        /**
         * Destructs a confine.
         */
        ~confine();

        /**
         * Prevents the confine from being copied.
         */
        confine(confine const&) = delete;
        /**
         * Prevents the confine from being copied.
         * @returns Returns this confine.
         */
        confine& operator=(confine const&) = delete;
        /**
         * Moves the given confine into this confine.
         * @param other The confine to move into this confine.
         */
        confine(confine&& other);
        /**
         * Moves the given confine into this confine.
         * @param other The confine to move into this confine.
         * @return Returns this confine.
         */
        confine& operator=(confine&& other);

        /**
         * Determines if the confined resolution is allowed or not.
         * @param facter The Ruby facter module to resolve facts with.
         * @return Returns true if the resolution is allowed or false if it is not.
         */
        bool allowed(module& facter) const;

     private:
        api const& _ruby;
        VALUE _fact;
        VALUE _expected;
        VALUE _block;
    };

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_CONFINE_HPP_
