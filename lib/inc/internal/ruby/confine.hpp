/**
 * @file
 * Declares the class for Ruby fact confines.
 */
#pragma once

#include <leatherman/ruby/api.hpp>
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
         * @param fact The fact name to confine to.  Can be nil if a block is given.
         * @param expected The expected value or values for the given fact.  Can be nil if no fact given.
         * @param block The block to call for the confine.  Can be nil.
         */
        confine(leatherman::ruby::VALUE fact, leatherman::ruby::VALUE expected, leatherman::ruby::VALUE block);

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
         * Determines if the confine is suitable or not.
         * @param facter The Ruby Facter module to resolve facts with.
         * @return Returns true if the confine is suitable or false if it is not.
         */
        bool suitable(module& facter) const;

     private:
        confine(confine const&) = delete;
        confine& operator=(confine const&) = delete;
        void mark() const;

        friend struct resolution;

        leatherman::ruby::VALUE _fact;
        leatherman::ruby::VALUE _expected;
        leatherman::ruby::VALUE _block;
    };

}}  // namespace facter::ruby
