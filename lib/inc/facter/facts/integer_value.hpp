#ifndef FACTER_FACTS_INTEGER_VALUE_HPP_
#define FACTER_FACTS_INTEGER_VALUE_HPP_

#include <boost/lexical_cast.hpp>

#include "value.hpp"

namespace facter { namespace facts {

    /**
     * Represents a simple integer value.
     */
    struct integer_value : value
    {
        /**
         * Constructs a integer_value.
         * @param value The integer value.
         */
        explicit integer_value(int64_t value) :
            _value(value)
        {
        }

        /**
         * Constructs a integer_value.
         * @param value The integer value.
         */
        explicit integer_value(std::string const& value)
        {
            try
            {
                _value = boost::lexical_cast<int64_t>(value);
            }
            catch (const boost::bad_lexical_cast& e)
            {
                // TODO: warn?
                _value = 0;
            }
        }

        // Force non-copyable
        integer_value(integer_value const&) = delete;
        integer_value& operator=(integer_value const&) = delete;

        // Allow movable
        integer_value(integer_value&&) = default;
        integer_value& operator=(integer_value&&) = default;

        /**
         * Converts the value to a string representation.
         * @return Returns the string representation of the value.
         */
        std::string to_string() const { return std::to_string(_value); }

        /**
         * Gets the integer value.
         * @return Returns the integer value.
         */
        int64_t const& value() const { return _value; }

     private:
        int64_t _value;
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_INTEGER_VALUE_HPP_

