#ifndef FACTER_FACTS_VALUE_HPP_
#define FACTER_FACTS_VALUE_HPP_

#include <string>
#include <functional>
#include <memory>
#include <iostream>

// Forward delcare needed rapidjson classes.
namespace rapidjson {
    class CrtAllocator;
    template <typename BaseAllocator> class MemoryPoolAllocator;
    template <typename Encoding, typename Allocator> class GenericValue;
    template<typename CharType> struct UTF8;
    typedef GenericValue<UTF8<char>, MemoryPoolAllocator<CrtAllocator>> Value;
    typedef MemoryPoolAllocator<CrtAllocator> Allocator;
    template <typename Encoding, typename Allocator> class GenericDocument;
    typedef GenericDocument<UTF8<char>, MemoryPoolAllocator<CrtAllocator>> Document;
}

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
         * Destructs a value.
         */
        virtual ~value() {}

        // Force non-copyable
        value(value const&) = delete;
        value& operator=(value const&) = delete;

        // Allow movable
        value(value&&) = default;
        value& operator=(value&&) = default;

        /**
         * Converts the value to a JSON value.
         * @param allocator The allocator to use for creating the JSON value.
         * @param value The returned JSON value.
         */
        virtual void to_json(rapidjson::Allocator& allocator, rapidjson::Value& value) const = 0;

     protected:
        /**
          * Writes the value to the given stream.
          * @param os The stream to write to.
          * @returns Returns the stream being written to.
          */
        virtual std::ostream& write(std::ostream& os) const = 0;
        friend std::ostream& operator<<(std::ostream& os, value const& val);
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

    /**
     * Insertion operator for value.
     * @param os The output stream to write to.
     * @param val The value to write to the stream.
     * @return Returns the given output stream.
     */
    std::ostream& operator<<(std::ostream& os, value const& val);

}}  // namespace facter::facts

#endif  // FACTER_FACTS_VALUE_HPP_
