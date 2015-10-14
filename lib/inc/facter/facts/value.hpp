/**
 * @file
 * Declares the base fact value type.
 */
#pragma once

#include "../export.h"
#include <string>
#include <functional>
#include <memory>
#include <iostream>

// Forward declare needed yaml-cpp classes.
namespace YAML {
    class Emitter;
}

// Forward delcare needed rapidjson classes.
namespace rapidjson {
    class CrtAllocator;
    template <typename Encoding, typename Allocator> class GenericValue;
    template <typename Encoding, typename Allocator, typename StackAllocator> class GenericDocument;
    template<typename CharType> struct UTF8;
}

extern "C" {
    /**
     * Simple structure to store enumeration callbacks.
     */
    typedef struct _enumeration_callbacks enumeration_callbacks;
}

namespace facter { namespace facts {

    /**
     * Typedef for RapidJSON allocator.
     */
    typedef typename rapidjson::CrtAllocator json_allocator;
    /**
     * Typedef for RapidJSON value.
     */
    typedef typename rapidjson::GenericValue<rapidjson::UTF8<char>, json_allocator> json_value;
    /**
     * Typedef for RapidJSON document.
     */
    typedef typename rapidjson::GenericDocument<rapidjson::UTF8<char>, json_allocator, json_allocator> json_document;

    /**
     * Base class for values.
     * This type can be moved but cannot be copied.
     */
    struct LIBFACTER_EXPORT value
    {
        /**
         * Constructs a value.
         * @param hidden True if the fact is hidden from output by default or false if not.
         */
        value(bool hidden = false) :
            _hidden(hidden)
        {
        }

        /**
         * Destructs a value.
         */
        virtual ~value() = default;

        /**
         * Moves the given value into this value.
         * @param other The value to move into this value.
         */
        // Visual Studio 12 still doesn't allow default for move constructor.
        value(value&& other)
        {
            _hidden = other._hidden;
        }

        /**
         * Moves the given value into this value.
         * @param other The value to move into this value.
         * @return Returns this value.
         */
        // Visual Studio 12 still doesn't allow default for move assignment.
        value& operator=(value&& other)
        {
            _hidden = other._hidden;
            return *this;
        }

        /**
         * Determines if the value is hidden from output by default.
         * @return Returns true if the value is hidden from output by default or false if it is not.
         */
        bool hidden() const
        {
            return _hidden;
        }

        /**
         * Converts the value to a JSON value.
         * @param allocator The allocator to use for creating the JSON value.
         * @param value The returned JSON value.
         */
        virtual void to_json(json_allocator& allocator, json_value& value) const = 0;

        /**
          * Writes the value to the given stream.
          * @param os The stream to write to.
          * @param quoted True if string values should be quoted or false if not.
          * @param level The current indentation level.
          * @returns Returns the stream being written to.
          */
        virtual std::ostream& write(std::ostream& os, bool quoted = true, unsigned int level = 1) const = 0;

        /**
          * Writes the value to the given YAML emitter.
          * @param emitter The YAML emitter to write to.
          * @returns Returns the given YAML emitter.
          */
        virtual YAML::Emitter& write(YAML::Emitter& emitter) const = 0;

     private:
        value(value const&) = delete;
        value& operator=(value const&) = delete;

        bool _hidden;
    };

    /**
     * Utility function for making a value.
     * @tparam T The type of the value being constructed.
     * @tparam Args The variadic types for the value's constructor.
     * @param args The arguments to the value's constructor.
     * @return Returns a unique pointer to the constructed value.
     */
    template<typename T, typename ...Args>
    std::unique_ptr<T> make_value(Args&& ...args)
    {
        return std::unique_ptr<T>(new T(std::forward<Args>(args)...));
    }

}}  // namespace facter::facts
