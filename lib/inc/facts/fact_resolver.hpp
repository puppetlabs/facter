#ifndef LIB_INC_FACTS_FACT_RESOLVER_HPP_
#define LIB_INC_FACTS_FACT_RESOLVER_HPP_

#include <vector>
#include <memory>
#include <string>

// Forward declare RE2 so users of this header don't have to include re2
namespace re2 {
    class RE2;
}

namespace cfacter { namespace facts {

    /**
     * Thrown when a circular fact resolution is detected.
     */
    struct circular_resolution_exception : std::runtime_error
    {
        /**
         * Constructs a circular_resolution_exception.
         * @param message The exception message.
         */
        explicit circular_resolution_exception(std::string const& message) : std::runtime_error(message) {}
    };

    /**
     * Thrown when a resolver is constructed with an invalid fact name pattern.
     */
    struct invalid_name_pattern_exception : std::runtime_error
    {
        /**
         * Constructs a invalid_name_pattern_exception.
         * @param message The exception message.
         */
        explicit invalid_name_pattern_exception(std::string const& message) : std::runtime_error(message) {}
    };

    /**
     * Utility type for managing resolution cycles.
     */
    struct cycle_guard
    {
        explicit cycle_guard(bool& value) :
            _value(value)
        {
            _value = true;
        }

        ~cycle_guard()
        {
            _value = false;
        }

     private:
        bool& _value;
    };

    struct fact_map;

    /**
     * Base class for fact resolvers.
     * A fact resolver is responsible for resolving one or more facts.
     */
    struct fact_resolver
    {
        /**
         * Constructs a fact_resolver.
         * @param names The fact names the resolver is responsible for.
         * @param patterns Regular expression patterns for additional ("dynamic") facts the resolver is responsible for.
         */
        fact_resolver(std::vector<std::string>&& names, std::vector<std::string> const& patterns = {});

        /**
         * Destructs the fact_resolver.
         */
        virtual ~fact_resolver();

        // Force non-copyable
        fact_resolver(fact_resolver const&) = delete;
        fact_resolver& operator=(fact_resolver const&) = delete;

        // Allow movable
        fact_resolver(fact_resolver&&) = default;
        fact_resolver& operator=(fact_resolver&&) = default;

        /**
         * Gets the fact names the resolver is responsible for resolving.
         * @return Returns a vector of fact names.
         */
        std::vector<std::string> const& names() const { return _names; }

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        void resolve(fact_map& facts);

        /**
         * Checks whether or not the resolver can resolve the given fact name.
         * Note that it is not required to return true if the given name is in the names vector.
         * @param name The fact name to check.
         * @return Returns true if the resolver can resolve the given name or false if it cannot.
         */
        bool can_resolve(std::string const& name) const;

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts) = 0;

     private:
        std::vector<std::string> _names;
        std::vector<std::unique_ptr<re2::RE2>> _regexes;
        bool _resolving;
    };

}}  // namespace cfacter::facts

#endif  // LIB_INC_FACTS_FACT_RESOLVER_HPP_

