/**
 * @file
 * Declares the Ruby Facter::Core::Aggregate class.
 */
#pragma once

#include "resolution.hpp"
#include "chunk.hpp"
#include <string>
#include <map>

namespace facter { namespace ruby {

    /**
     * Represents the Ruby Facter::Core::Aggregate class.
     */
    struct aggregate_resolution : resolution
    {
        /**
         * Defines the Facter::Core::Aggregate class.
         * @return Returns the Facter::Core::Aggregate class.
         */
        static leatherman::ruby::VALUE define();

        /**
         * Creates an instance of the Facter::Core::Aggregate class.
         * @return Returns the new instance.
         */
        static leatherman::ruby::VALUE create();

        /**
         * Gets the value of the resolution.
         * @return Returns the value of the resolution or nil if the value did not resolve.
         */
        virtual leatherman::ruby::VALUE value();

        /**
         * Finds the value of the given chunk.
         * @param name The name of the chunk to find the value of.
         * @return Returns the value of the chunk or nil if the chunk is not found.
         */
        leatherman::ruby::VALUE find_chunk(leatherman::ruby::VALUE name);

        /**
         * Defines a chunk.
         * @param name The name of the chunk.
         * @param options The options for defining the chunk.
         */
        void define_chunk(leatherman::ruby::VALUE name, leatherman::ruby::VALUE options);

     private:
        // Construction and assignment
        aggregate_resolution();
        aggregate_resolution(aggregate_resolution const&) = delete;
        aggregate_resolution& operator=(aggregate_resolution const&) = delete;
        aggregate_resolution(aggregate_resolution&& other) = delete;
        aggregate_resolution& operator=(aggregate_resolution&& other) = delete;

        // Ruby lifecycle functions
        static leatherman::ruby::VALUE alloc(leatherman::ruby::VALUE klass);
        static void mark(void* data);
        static void free(void* data);

        // Methods called from Ruby
        static leatherman::ruby::VALUE ruby_chunk(int argc, leatherman::ruby::VALUE* argv, leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_aggregate(leatherman::ruby::VALUE self);
        static leatherman::ruby::VALUE ruby_merge_hashes(leatherman::ruby::VALUE obj, leatherman::ruby::VALUE context, int argc, leatherman::ruby::VALUE* argv);

        // Helper functions
        static leatherman::ruby::VALUE deep_merge(leatherman::ruby::api const& ruby, leatherman::ruby::VALUE left, leatherman::ruby::VALUE right);

        leatherman::ruby::VALUE _self;
        leatherman::ruby::VALUE _block;
        std::map<leatherman::ruby::VALUE, ruby::chunk> _chunks;
    };

}}  // namespace facter::ruby
