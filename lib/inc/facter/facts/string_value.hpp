#ifndef FACTER_FACTS_STRING_VALUE_HPP_
#define FACTER_FACTS_STRING_VALUE_HPP_

#include "value.hpp"

namespace facter { namespace facts {

    /**
     * Represents a simple string value.
     */
    struct string_value : value
    {
        /**
         * Constructs a string_value.
         * @param value The string value.
         */
        explicit string_value(std::string&& value) :
            _value(std::move(value))
        {
        }

        /**
         * Constructs a string_value.
         * @param value The string value.
         */
        explicit string_value(std::string const& value) :
            _value(value)
        {
        }

        // Force non-copyable
        string_value(string_value const&) = delete;
        string_value& operator=(string_value const&) = delete;

        // Allow movable
        string_value(string_value&&) = default;
        string_value& operator=(string_value&&) = default;

        /**
         * Converts the value to a string representation.
         * @return Returns the string representation of the value.
         */
        std::string to_string() const;

        /**
         * Gets the string value.
         * @return Returns the string value.
         */
        std::string const& value() const { return _value; }

     private:
        std::string _value;
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_STRING_VALUE_HPP_

