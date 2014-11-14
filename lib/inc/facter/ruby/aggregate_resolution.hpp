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
        static VALUE define();

        /**
         * Creates an instance of the Facter::Core::Aggregate class.
         * @return Returns the new instance.
         */
        static VALUE create();

        /**
         * Gets the value of the resolution.
         * @return Returns the value of the resolution or nil if the value did not resolve.
         */
        virtual VALUE value();

        /**
         * Finds the value of the given chunk.
         * @param name The name of the chunk to find the value of.
         * @return Returns the value of the chunk or nil if the chunk is not found.
         */
        VALUE find_chunk(VALUE name);

        /**
         * Defines a chunk.
         * @param name The name of the chunk.
         * @param options The options for defining the chunk.
         */
        void define_chunk(VALUE name, VALUE options);

     private:
        // Construction and assignment
        aggregate_resolution();
        aggregate_resolution(aggregate_resolution const&) = delete;
        aggregate_resolution& operator=(aggregate_resolution const&) = delete;
        aggregate_resolution(aggregate_resolution&& other) = delete;
        aggregate_resolution& operator=(aggregate_resolution&& other) = delete;

        // Ruby lifecycle functions
        static VALUE alloc(VALUE klass);
        static void mark(void* data);
        static void free(void* data);

        // Methods called from Ruby
        static VALUE ruby_chunk(int argc, VALUE* argv, VALUE self);
        static VALUE ruby_aggregate(VALUE self);
        static VALUE ruby_merge_hashes(VALUE obj, VALUE context, int argc, VALUE* argv);

        // Helper functions
        static VALUE deep_merge(api const& ruby, VALUE left, VALUE right);

        VALUE _block;
        std::map<VALUE, ruby::chunk> _chunks;
    };

}}  // namespace facter::ruby
