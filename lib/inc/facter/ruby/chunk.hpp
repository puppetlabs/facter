/**
 * @file
 * Declares the class for aggregate resolution chunks.
 */
#ifndef FACTER_RUBY_CHUNK_HPP_
#define FACTER_RUBY_CHUNK_HPP_

#include "api.hpp"

namespace facter { namespace ruby {

    struct aggregate_resolution;

    /**
     * Represents a aggregate resolution chunk.
     */
    struct chunk
    {
        /**
         * Constructs a chunk.
         * @param ruby The Ruby API to use.
         * @param dependencies The symbol or array of symbols this chunk depends on.
         * @param block The block to run to resolve the chunk.
         */
        chunk(api const& ruby, VALUE dependencies, VALUE block);

        /**
         * Destructs a chunk.
         */
        ~chunk();

        /**
         * Prevents the chunk from being copied.
         */
        chunk(chunk const&) = delete;
        /**
         * Prevents the chunk from being copied.
         * @returns Returns this chunk.
         */
        chunk& operator=(chunk const&) = delete;
        /**
         * Moves the given chunk into this chunk.
         * @param other The chunk to move into this chunk.
         */
        chunk(chunk&& other);
        /**
         * Moves the given chunk into this chunk.
         * @param other The chunk to move into this chunk.
         * @return Returns this chunk.
         */
        chunk& operator=(chunk&& other);

        /**
         * Gets the value of the chunk.
         * @param resolution The aggregate resolution being resolved.
         * @return Returns the value of the chunk.
         */
        VALUE value(aggregate_resolution& resolution);

        /**
         * Gets the chunk's dependencies.
         * @return Returns the chunk's dependencies.
         */
        VALUE dependencies() const;

        /**
         * Sets the chunk's dependencies.
         * @param dependencies The chunk's dependencies.
         */
        void set_dependencies(VALUE dependencies);

        /**
         * Gets the chunk's block.
         * @return Returns the chunk's block.
         */
        VALUE block() const;

        /**
         * Sets the chunk's block.
         * @param block The chunk's block.
         */
        void set_block(VALUE block);

     private:
        api const& _ruby;
        VALUE _dependencies;
        VALUE _block;
        VALUE _value;
        bool _resolved;
        bool _resolving;
    };

}}  // namespace facter::ruby

#endif  // FACTER_RUBY_CHUNK_HPP_
