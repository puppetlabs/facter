#ifndef FACTER_FACTS_VALUE_HPP_
#define FACTER_FACTS_VALUE_HPP_

#include <string>
#include <functional>
#include <memory>

namespace facter { namespace facts {

    /**
     * Base class for values.
     */
    struct value
    {
        /**
         * Constructs a value.
         */
        value() {}

        /**
         * Converts the value to a string representation.
         * @return Returns the string representation of the value.
         */
        virtual std::string to_string() const = 0;

        // Force non-copyable
        value(value const&) = delete;
        value& operator=(value const&) = delete;

        // Allow movable
        value(value&&) = default;
        value& operator=(value&&) = default;
    };

    /**
     * Utility function for making a value.
     * @tparam T The type of the value being constructed.
     * @tparam Args The variadic types for the value's constructor.
     * @param args The arguments to the value's constructor.
     * @return Returns a unique pointer to the constructed value.
     */
    template<typename T, typename ...Args>
    std::unique_ptr<value> make_value(Args&& ...args)
    {
        return std::unique_ptr<value>(new T(std::forward<Args>(args)...));
    }

}}  // namespace facter::facts

#endif  // FACTER_FACTS_VALUE_HPP_

