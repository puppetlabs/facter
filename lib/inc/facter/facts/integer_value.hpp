#ifndef FACTER_FACTS_INTEGER_VALUE_HPP_
#define FACTER_FACTS_INTEGER_VALUE_HPP_

#include "value.hpp"
#include <cstdint>

namespace facter { namespace facts {

    /**
     * Represents a simple integer value.
     */
    struct integer_value : value
    {
        /**
         * Constructs an integer value.
         * @param value The integer value.
         */
        explicit integer_value(int64_t value) :
            _value(value)
        {
        }

        /**
         * Constructs a integer_value.
         * @param value The integer value as a string.
         */
        explicit integer_value(std::string const& value);

        // Force non-copyable
        integer_value(integer_value const&) = delete;
        integer_value& operator=(integer_value const&) = delete;

        // Allow movable
        integer_value(integer_value&&) = default;
        integer_value& operator=(integer_value&&) = default;

        /**
         * Converts the value to a JSON value.
         * @param allocator The allocator to use for creating the JSON value.
         * @param value The returned JSON value.
         */
        virtual void to_json(rapidjson::Allocator& allocator, rapidjson::Value& value) const;

        /**
         * Gets the integer value.
         * @return Returns the integer value.
         */
        int64_t const& value() const { return _value; }

     protected:
        /**
          * Writes the value to the given stream.
          * @param os The stream to write to.
          * @returns Returns the stream being written to.
          */
        virtual std::ostream& write(std::ostream& os) const;

     private:
        int64_t _value;
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_INTEGER_VALUE_HPP_

