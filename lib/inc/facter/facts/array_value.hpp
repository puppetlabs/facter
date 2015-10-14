/**
 * @file
 * Declares the fact value for arrays.
 */
#pragma once

#include "value.hpp"
#include "../export.h"
#include <vector>
#include <memory>
#include <functional>

namespace facter { namespace facts {

    /**
     * Represents an array of values.
     * This type can be moved but cannot be copied.
     */
    struct LIBFACTER_EXPORT array_value : value
    {
        /**
         * Constructs an array_value.
         * @param hidden True if the fact is hidden from output by default or false if not.
         */
        array_value(bool hidden = false) :
            value(hidden)
        {
        }

        /**
         * Prevents the array_value from being copied.
         */
        array_value(array_value const&) = delete;

        /**
         * Prevents the array_value from being copied.
         * @returns Returns this array_value.
         */
        array_value& operator=(array_value const&) = delete;

        /**
         * Moves the given array_value into this array_value.
         * @param other The array_value to move into this array_value.
         */
        // Visual Studio 12 still doesn't allow default for move constructor.
        array_value(array_value&& other);

        /**
         * Moves the given array_value into this array_value.
         * @param other The array_value to move into this array_value.
         * @return Returns this array_value.
         */
        // Visual Studio 12 still doesn't allow default for move assignment.
        array_value& operator=(array_value&& other);

        /**
         * Adds a value to the array.
         * @param value The value to add to the array.
         */
        void add(std::unique_ptr<value> value);

        /**
         * Checks to see if the array is empty.
         * @return Returns true if the array is empty or false if it is not.
         */
        bool empty() const;

        /**
         * Gets the size of the array.
         * @return Returns the number of values in the array.
         */
        size_t size() const;

        /**
         * Enumerates all facts in the array.
         * @param func The callback function called for each value in the array.
         */
        void each(std::function<bool(value const*)> func) const;

        /**
         * Converts the value to a JSON value.
         * @param allocator The allocator to use for creating the JSON value.
         * @param value The returned JSON value.
         */
        virtual void to_json(json_allocator& allocator, json_value& value) const override;

        /**
         * Gets the element at the given index.
         * @tparam T The expected type of the value.
         * @param i The index in the array to get the element at.
         * @return Returns the value at the given index or nullptr if the value is not of the expected type.
         */
        template <typename T = value> T const* get(size_t i) const
        {
            return dynamic_cast<T const*>(_elements.at(i).get());
        }

        /**
         * Gets the value at the given index.
         * @param i The index in the array to get the element at.
         * @return Returns the value at the given index.
         */
        value const* operator[](size_t i) const;

        /**
          * Writes the value to the given stream.
          * @param os The stream to write to.
          * @param quoted True if string values should be quoted or false if not.
          * @param level The current indentation level.
          * @returns Returns the stream being written to.
          */
        virtual std::ostream& write(std::ostream& os, bool quoted = true, unsigned int level = 1) const override;

        /**
          * Writes the value to the given YAML emitter.
          * @param emitter The YAML emitter to write to.
          * @returns Returns the given YAML emitter.
          */
        virtual YAML::Emitter& write(YAML::Emitter& emitter) const override;

     private:
        std::vector<std::unique_ptr<value>> _elements;
    };

}}  // namespace facter::facts
