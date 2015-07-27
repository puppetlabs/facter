/**
 * @file
 * Declares the class for aggregate resolution chunks.
 */
#pragma once

#include <leatherman/ruby/api.hpp>

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
        chunk(leatherman::ruby::VALUE dependencies, leatherman::ruby::VALUE block);

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
        leatherman::ruby::VALUE value(aggregate_resolution& resolution);

        /**
         * Gets the chunk's dependencies.
         * @return Returns the chunk's dependencies.
         */
        leatherman::ruby::VALUE dependencies() const;

        /**
         * Sets the chunk's dependencies.
         * @param dependencies The chunk's dependencies.
         */
        void dependencies(leatherman::ruby::VALUE dependencies);

        /**
         * Gets the chunk's block.
         * @return Returns the chunk's block.
         */
        leatherman::ruby::VALUE block() const;

        /**
         * Sets the chunk's block.
         * @param block The chunk's block.
         */
        void block(leatherman::ruby::VALUE block);

     private:
        chunk(chunk const&) = delete;
        chunk& operator=(chunk const&) = delete;
        void mark() const;

        friend struct aggregate_resolution;

        leatherman::ruby::VALUE _dependencies;
        leatherman::ruby::VALUE _block;
        leatherman::ruby::VALUE _value;
        bool _resolved;
        bool _resolving;
    };

}}  // namespace facter::ruby
