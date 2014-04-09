#ifndef __ARRAY_VALUE_HPP__
#define	__ARRAY_VALUE_HPP__

#include "value.hpp"
#include <vector>
#include <memory>

namespace cfacter { namespace facts {

    /**
     * Represents an array of values.
     */
    struct array_value : value
    {
        /**
         * Constructs an array_value.
         */
        array_value()
        {
        }

        /**
         * Constructs an array value.
         * @param elements The elements that make up the array.
         */
        array_value(std::vector<std::unique_ptr<value>>&& elements) :
            _elements(std::move(elements))
        {
        }

        // Force non-copyable
        array_value(array_value const&) = delete;
        array_value& operator=(array_value const&) = delete;

        // Allow movable
        array_value(array_value&&) = default;
        array_value& operator=(array_value&&) = default;

        /**
         * Converts the value to a string representation.
         * @return Returns the string representation of the value.
         */
        std::string to_string() const;

        /**
         * Gets the vector of elements in the array.
         * @return Returns the vector of elements in the array.
         */
        std::vector<std::unique_ptr<value>>& elements() { return _elements; }

        /**
         * Gets the vector of elements in the array.
         * @return Returns the vector of elements in the array.
         */
        std::vector<std::unique_ptr<value>> const& elements() const { return _elements; }

    private:
        std::vector<std::unique_ptr<value>> _elements;
    };

} } // namespace cfacter::facts

#endif

