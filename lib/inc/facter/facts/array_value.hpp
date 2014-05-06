#ifndef FACTER_FACTS_ARRAY_VALUE_HPP_
#define FACTER_FACTS_ARRAY_VALUE_HPP_

#include "value.hpp"
#include <vector>
#include <memory>

namespace facter { namespace facts {

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
        explicit array_value(std::vector<std::unique_ptr<value>>&& elements) :
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
         * Converts the value to a JSON value.
         * @param allocator The allocator to use for creating the JSON value.
         * @param value The returned JSON value.
         */
        virtual void to_json(rapidjson::Allocator& allocator, rapidjson::Value& value) const;

        /**
         * Gets the vector of elements in the array.
         * @return Returns the vector of elements in the array.
         */
        std::vector<std::unique_ptr<value>> const& elements() const { return _elements; }

        /**
         * Gets the value at the given index.
         * @param i The index in the array to get the element at.
         * @return Returns the value at the given index.
         */
        value const* operator[](size_t i) const { return _elements.at(i).get(); }

     protected:
        /**
          * Writes the value to the given stream.
          * @param os The stream to write to.
          * @returns Returns the stream being written to.
          */
        virtual std::ostream& write(std::ostream& os) const;

     private:
        std::vector<std::unique_ptr<value>> _elements;
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_ARRAY_VALUE_HPP_
