/**
 * @file
 * Declares the Ruby simple resolution class.
 */
#ifndef FACTER_RUBY_SIMPLE_RESOLUTION_HPP_
#define FACTER_RUBY_SIMPLE_RESOLUTION_HPP_

#include "resolution.hpp"

namespace facter { namespace ruby {

    /**
     * Represents the "simple" resolution that uses "setcode".
     */
    struct simple_resolution : resolution
    {
        /**
         * Constructs a simple resolution.
         * @param ruby The Ruby API to use.
         */
        explicit simple_resolution(api const& ruby);

        /**
         * Destructs the simple resolution.
         */
        ~simple_resolution();

        /**
         * Prevents the simple_resolution from being copied.
         */
        simple_resolution(simple_resolution const&) = delete;
        /**
         * Prevents the simple_resolution from being copied.
         * @returns Returns this simple_resolution.
         */
        simple_resolution& operator=(simple_resolution const&) = delete;
        /**
         * Moves the given simple_resolution into this simple_resolution.
         * @param other The simple_resolution to move into this simple_resolution.
         */
        simple_resolution(simple_resolution&& other);
        /**
         * Moves the given simple_resolution into this simple_resolution.
         * @param other The simple_resolution to move into this simple_resolution.
         * @return Returns this simple_resolution.
         */
        simple_resolution& operator=(simple_resolution&& other);

        /**
         * Defines the Ruby simple resolution class.
         * @param ruby the Ruby API to use.
         * @return Returns the Ruby class that defines the simple resolution.
         */
        static VALUE define(api const& ruby);

        /**
         * Resolves to a value.
         * @return Returns the resolved value or nil if the fact was not resolved.
         */
        virtual VALUE resolve();

     private:
        static VALUE setcode_thunk(int argc, VALUE* argv, VALUE self);
        static VALUE which_thunk(VALUE self, VALUE binary);
        static VALUE exec_thunk(VALUE self, VALUE command);

        std::string _command;
        VALUE _block;
    };

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_SIMPLE_RESOLUTION_HPP_
