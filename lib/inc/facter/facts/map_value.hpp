/**
 * @file
 * Declares the fact value for maps (associative array).
 */
#pragma once

#include "value.hpp"
#include "../export.h"
#include <map>
#include <string>
#include <memory>
#include <functional>

namespace facter { namespace facts {

    /**
     * Represents a fact value that maps fact names to values.
     * This type can be moved but cannot be copied.
     */
    struct LIBFACTER_EXPORT map_value : value
    {
        /**
         * Constructs a map value.
         * @param hidden True if the fact is hidden from output by default or false if not.
         */
        map_value(bool hidden = false) :
            value(hidden)
        {
        }

        /**
         * Prevents the map_value from being copied.
         */
        map_value(map_value const&) = delete;

        /**
         * Prevents the map_value from being copied.
         * @returns Returns this map_value.
         */
        map_value& operator=(map_value const&) = delete;

        /**
         * Moves the given map_value into this map_value.
         * @param other The map_value to move into this map_value.
         */
        // Visual Studio 12 still doesn't allow default for move constructor.
        map_value(map_value&& other);

        /**
         * Moves the given map_value into this map_value.
         * @param other The map_value to move into this map_value.
         * @return Returns this map_value.
         */
        // Visual Studio 12 still doesn't allow default for move assignment.
        map_value& operator=(map_value&& other);

        /**
         * Adds a value to the map.
         * @param name The name of map element.
         * @param value The value of the map element.
         */
        void add(std::string name, std::unique_ptr<value> value);

        /**
         * Checks to see if the map is empty.
         * @return Returns true if the map is empty or false if it is not.
         */
        bool empty() const;

        /**
         * Gets the size of the map.
         * @return Returns the number of elements in the map.
         */
        size_t size() const;

        /**
         * Enumerates all facts in the map.
         * @param func The callback function called for each element in the map.
         */
        void each(std::function<bool(std::string const&, value const*)> func) const;

        /**
         * Converts the value to a JSON value.
         * @param allocator The allocator to use for creating the JSON value.
         * @param value The returned JSON value.
         */
        virtual void to_json(json_allocator& allocator, json_value& value) const override;

        /**
         * Gets the value in the map of the given name.
         * @tparam T The expected type of the value.
         * @param name The name of the value in the map to get.
         * @return Returns the value in the map or nullptr if the value is not in the map or expected type.
         */
        template <typename T = value> T const* get(std::string const& name) const
        {
            return dynamic_cast<T const*>(this->operator [](name));
        }

        /**
         * Gets the value in the map of the given name.
         * @param name The name of the value in the map to get.
         * @return Returns the value in the map or nullptr if the value is not in the map.
         */
        value const* operator[](std::string const& name) const;

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
        std::map<std::string, std::unique_ptr<value>> _elements;
    };

}}  // namespace facter::facts
