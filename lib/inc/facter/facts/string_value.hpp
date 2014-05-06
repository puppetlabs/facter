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
         * Converts the value to a JSON value.
         * @param allocator The allocator to use for creating the JSON value.
         * @param value The returned JSON value.
         */
        virtual void to_json(rapidjson::Allocator& allocator, rapidjson::Value& value) const;

        /**
         * Gets the string value.
         * @return Returns the string value.
         */
        std::string const& value() const { return _value; }

     protected:
        /**
          * Writes the value to the given stream.
          * @param os The stream to write to.
          * @returns Returns the stream being written to.
          */
        virtual std::ostream& write(std::ostream& os) const;

     private:
        std::string _value;
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_STRING_VALUE_HPP_

