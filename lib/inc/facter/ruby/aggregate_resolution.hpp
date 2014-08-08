/**
 * @file
 * Declares the Ruby aggregate resolution class.
 */
#ifndef FACTER_RUBY_AGGREGATE_RESOLUTION_HPP_
#define FACTER_RUBY_AGGREGATE_RESOLUTION_HPP_

#include "resolution.hpp"
#include "chunk.hpp"
#include <string>
#include <map>

namespace facter { namespace ruby {

    /**
     * Represents the "aggregate" resolution that uses "chunk" and "aggregate".
     */
    struct aggregate_resolution : resolution
    {
        /**
         * Constructs a aggregate resolution.
         * @param ruby The Ruby API to use.
         */
        explicit aggregate_resolution(api const& ruby);

        /**
         * Destructs the aggregate resolution.
         */
        ~aggregate_resolution();

        /**
         * Prevents the aggregate_resolution from being copied.
         */
        aggregate_resolution(aggregate_resolution const&) = delete;
        /**
         * Prevents the aggregate_resolution from being copied.
         * @returns Returns this aggregate_resolution.
         */
        aggregate_resolution& operator=(aggregate_resolution const&) = delete;
        /**
         * Moves the given aggregate_resolution into this aggregate_resolution.
         * @param other The aggregate_resolution to move into this aggregate_resolution.
         */
        aggregate_resolution(aggregate_resolution&& other);
        /**
         * Moves the given aggregate_resolution into this aggregate_resolution.
         * @param other The aggregate_resolution to move into this aggregate_resolution.
         * @return Returns this aggregate_resolution.
         */
        aggregate_resolution& operator=(aggregate_resolution&& other);

        /**
         * Defines the Ruby aggregate resolution class.
         * @param ruby the Ruby API to use.
         * @return Returns the Ruby class that defines the aggregate resolution.
         */
        static VALUE define(api const& ruby);

        /**
         * Resolves to a value.
         * @return Returns the resolved value or nil if the fact was not resolved.
         */
        virtual VALUE resolve();

        /**
         * Finds the value of the given chunk.
         * @param name The name of the chunk to find the value of.
         * @return Returns the value of the chunk or nil if the chunk is not found.
         */
        VALUE find_chunk(std::string const& name);

     private:
        static VALUE chunk_thunk(int argc, VALUE* argv, VALUE self);
        static VALUE aggregate_thunk(VALUE self);
        static VALUE deep_merge(api const& ruby, VALUE left, VALUE right);
        static VALUE merge_hashes(VALUE proc, VALUE proc_value, int argc, VALUE* argv);

        VALUE _aggregate;
        std::map<std::string, chunk> _chunks;
    };

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_AGGREGATE_RESOLUTION_HPP_
