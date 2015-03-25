/**
 * @file
 * Declares utility type for passing a set of options.
 */
#pragma once

#include "../export.h"
#include <numeric>
#include <string>
#include <initializer_list>

namespace facter { namespace util {
    /**
     * Represents a set of options (flags).
     * Adapted from http://stackoverflow.com/a/4226975/530189
     * @tparam T The enum class type that makes up the available options.
     */
    template <typename T>
    struct option_set
    {
        /**
         * The underlying enum type for the option set.
         */
        typedef T enum_type;

        /**
         * The value type for the enum type.
         */
        typedef typename std::underlying_type<T>::type value_type;

        /**
         * Constructs an empty option_set.
         */
        option_set() : option_set(value_type(0))
        {
        }

        /**
         * Constructs an option_set with the given list of options.
         * @param values The option values to store in the list.
         */
        option_set(std::initializer_list<enum_type> const& values)
        {
            // Simply bitwise OR all the values together.
            _value = std::accumulate(
                std::begin(values),
                std::end(values),
                value_type(0),
                [](value_type acc, enum_type value) {
                    return acc | static_cast<value_type>(value);
                });
        }

        /**
         * Constructs an option_set with an existing bitfield value.
         * @param value
         */
        explicit option_set(value_type value) : _value(value)
        {
        }

        /**
         * Gets the underlying value of the set.
         * @return Returns the underlying value of the set.
         */
        value_type value() const
        {
            return _value;
        }

        /**
         * Used to test if an option is present in the set.
         * @param option The option to check for.
         * @return Returns true if the option is in the set or false if it is not.
         */
        bool operator [](enum_type option) const
        {
           return test(option);
        }

        /**
         * Sets all options to true.
         * @return Returns this option_set.
         */
        option_set& set_all()
        {
            _value = ~value_type(0);
            return *this;
        }

        /**
         * Sets the given option to true.
         * @param option The option to set to true.
         * @return Returns this option_set.
         */
        option_set& set(enum_type option)
        {
            _value |= static_cast<value_type>(option);
            return *this;
        }

        /**
         * Clears the given option from the set.
         * @param option The option to clear.
         * @return Returns this option_set.
         */
        option_set& clear(enum_type option)
        {
            _value &= ~static_cast<value_type>(option);
            return *this;
        }

        /**
         * Resets the option_set by clearing all options.
         * @return Returns this option_set.
         */
        option_set& reset()
        {
            _value = value_type(0);
            return *this;
        }

        /**
         * Toggles all options in the set.
         * @return Returns this option_set.
         */
        option_set& toggle()
        {
            _value = ~_value;
            return *this;
        }

        /**
         * Toggles a specific option in the set.
         * @param option The option to toggle.
         * @return Returns this option_set.
         */
        option_set& toggle(enum_type option)
        {
            _value ^= static_cast<value_type>(option);
            return *this;
        }

        /**
         * Gets the count of options in the set.
         * @return Returns the count of options in the set.
         */
        size_t count() const
        {
            // Do a simple bit count
            value_type bits = _value;
            size_t total = 0;
            for (; bits != 0; ++total)
            {
                bits &= bits - 1;  // clear the least significant bit set
            }
            return total;
        }

        /**
         * Gets the bit size of the option_set.
         * The size is based on how many bits are present in the underlying value_type.
         * @return Returns the bit size of the option_set.
         */
        constexpr size_t size() const
        {
            return sizeof(value_type)*8;
        }

        /**
         * Tests if the given option is in the set.
         * @param option The option to test for.
         * @return Returns true if the option is in the set or false if it is not.
         */
        bool test(enum_type option) const
        {
            return _value & static_cast<value_type>(option);
        }

        /**
         * Checks to see if the option_set is empty.
         * @return Returns true if the set is empty (no options) or false if there are options in the set.
         */
        bool empty() const
        {
            return _value == 0;
        }

     private:
        value_type _value;
    };

    /**
     * Bitwise AND operator for option_set.
     * @param lhs The lefthand option_set.
     * @param rhs The righthand option_set.
     * @return Returns an option_set that is the bitwise AND of the two given option_sets.
     */
    template<typename T>
    option_set<T> operator &(option_set<T> const& lhs, option_set<T> const& rhs)
    {
        return option_set<T>(lhs.value() & rhs.value());
    }

    /**
     * Bitwise OR operator for option_set.
     * @param lhs The lefthand option_set.
     * @param rhs The righthand option_set.
     * @return Returns an option_set that is the bitwise OR of the two given option_sets.
     */
    template<typename T>
    option_set<T> operator |(option_set<T> const& lhs, option_set<T> const& rhs)
    {
        return option_set<T>(lhs.value() | rhs.value());
    }

    /**
     * Bitwise XOR operator for option_set.
     * @param lhs The lefthand option_set.
     * @param rhs The righthand option_set.
     * @return Returns an option_set that is the bitwise XOR of the two given option_sets.
     */
    template<typename T>
    option_set<T> operator ^(option_set<T> const& lhs, option_set<T> const& rhs)
    {
        return option_set<T>(lhs.value() ^ rhs.value());
    }

}}  // namespace facter::util
