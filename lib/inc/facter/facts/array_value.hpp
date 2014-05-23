#ifndef FACTER_FACTS_ARRAY_VALUE_HPP_
#define FACTER_FACTS_ARRAY_VALUE_HPP_

#include "value.hpp"
#include <vector>
#include <memory>
#include <functional>

namespace facter { namespace facts {

    /**
     * Represents an array of values.
     */
    struct array_value : value
    {
        /**
         * Constructs an array_value.
         */
        array_value();

        // Force non-copyable
        array_value(array_value const&) = delete;
        array_value& operator=(array_value const&) = delete;

        // Allow movable
        array_value(array_value&&) = default;
        array_value& operator=(array_value&&) = default;

        /**
         * Adds a value to the array.
         * @param value The value to add to the array.
         */
        void add(std::unique_ptr<value>&& value);

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
        virtual void to_json(rapidjson::Allocator& allocator, rapidjson::Value& value) const;

        /**
         * Notifies the appropriate callback based on the type of the value.
         * @param name The fact name to pass to the callback.
         * @param callbacks The callbacks to use to notify.
         */
        virtual void notify(std::string const& name, enumeration_callbacks const* callbacks) const;

        /**
         * Gets the element at the given index.
         * @tparam T The expected type of the value.
         * @param i The index in the array to get the element at.
         * @return Returns the value at the given index or nullptr if the value is not of the expected type.
         */
        template <typename T> T const* get(size_t i) const
        {
            return dynamic_cast<T const*>(_elements.at(i).get());
        }

        /**
         * Gets the value at the given index.
         * @param i The index in the array to get the element at.
         * @return Returns the value at the given index.
         */
        value const* operator[](size_t i) const
        {
            return _elements.at(i).get();
        }

     protected:
        /**
          * Writes the value to the given stream.
          * @param os The stream to write to.
          * @returns Returns the stream being written to.
          */
        virtual std::ostream& write(std::ostream& os) const;

        /**
          * Writes the value to the given YAML emitter.
          * @param emitter The YAML emitter to write to.
          * @returns Returns the given YAML emitter.
          */
        virtual YAML::Emitter& write(YAML::Emitter& emitter) const;

     private:
        std::vector<std::unique_ptr<value>> _elements;
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_ARRAY_VALUE_HPP_
