/**
 * @file
 * Declares the class for aggregate resolution chunks.
 */
#pragma once

#include "api.hpp"

namespace facter { namespace ruby {

    struct aggregate_resolution;

    /**
     * Represents a aggregate resolution chunk.
     */
    struct chunk
    {
        /**
         * Constructs an aggregate resolution chunk.
         * @param dependencies The symbol or array of symbols this chunk depends on.
         * @param block The block to run to resolve the chunk.
         */
        chunk(VALUE dependencies, VALUE block);

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
        void dependencies(VALUE dependencies);

        /**
         * Gets the chunk's block.
         * @return Returns the chunk's block.
         */
        VALUE block() const;

        /**
         * Sets the chunk's block.
         * @param block The chunk's block.
         */
        void block(VALUE block);

     private:
        chunk(chunk const&) = delete;
        chunk& operator=(chunk const&) = delete;
        void mark() const;

        friend struct aggregate_resolution;

        VALUE _dependencies;
        VALUE _block;
        VALUE _value;
        bool _resolved;
        bool _resolving;
    };

}}  // namespace facter::ruby
