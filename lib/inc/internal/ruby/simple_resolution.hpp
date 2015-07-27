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
        static leatherman::ruby::VALUE define();

        /**
         * Creates an instance of the Facter::Util::Resolution class.
         * @return Returns the new instance.
         */
        static leatherman::ruby::VALUE create();

        /**
         * Gets the value of the resolution.
         * @return Returns the value of the resolution or nil if the value did not resolve.
         */
        virtual leatherman::ruby::VALUE value();

     private:
        // Construction and assignment
        simple_resolution();
        simple_resolution(simple_resolution const&) = delete;
        simple_resolution& operator=(simple_resolution const&) = delete;
        simple_resolution(simple_resolution&& other) = delete;
        simple_resolution& operator=(simple_resolution&& other) = delete;

        // Ruby lifecycle functions
        static leatherman::ruby::VALUE alloc(leatherman::ruby::VALUE klass);
        static void mark(void* data);
        static void free(void* data);

        static leatherman::ruby::VALUE ruby_setcode(int argc, leatherman::ruby::VALUE* argv, leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_which(leatherman::ruby::VALUE self, leatherman::ruby::VALUE binary);
        static leatherman::ruby::VALUE ruby_exec(leatherman::ruby::VALUE self, leatherman::ruby::VALUE command);

        leatherman::ruby::VALUE _self;
        leatherman::ruby::VALUE _block;
        leatherman::ruby::VALUE _command;
    };

}}  // namespace facter::ruby
