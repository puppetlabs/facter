/**
 * @file
 * Declares the Ruby Facter::Util::Resolution class.
 */
#pragma once

#include "resolution.hpp"

namespace facter { namespace ruby {

    /**
     * Represents the Ruby Facter::Util::Resolution class.
     */
    struct simple_resolution : resolution
    {
        /**
         * Defines the Facter::Util::Resolution class.
         * @return Returns theFacter::Util::Resolution class.
         */
        static VALUE define();

        /**
         * Creates an instance of the Facter::Util::Resolution class.
         * @return Returns the new instance.
         */
        static VALUE create();

        /**
         * Gets the value of the resolution.
         * @return Returns the value of the resolution or nil if the value did not resolve.
         */
        virtual VALUE value();

     private:
        // Construction and assignment
        simple_resolution();
        simple_resolution(simple_resolution const&) = delete;
        simple_resolution& operator=(simple_resolution const&) = delete;
        simple_resolution(simple_resolution&& other) = delete;
        simple_resolution& operator=(simple_resolution&& other) = delete;

        // Ruby lifecycle functions
        static VALUE alloc(VALUE klass);
        static void mark(void* data);
        static void free(void* data);

        static VALUE ruby_setcode(int argc, VALUE* argv, VALUE self);
        static VALUE ruby_which(VALUE self, VALUE binary);
        static VALUE ruby_exec(VALUE self, VALUE command);

        VALUE _self;
        VALUE _block;
        VALUE _command;
    };

}}  // namespace facter::ruby
