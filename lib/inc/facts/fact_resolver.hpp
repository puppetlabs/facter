#ifndef LIB_INC_FACTS_FACT_RESOLVER_HPP_
#define LIB_INC_FACTS_FACT_RESOLVER_HPP_

#include <vector>
#include <memory>
#include <string>
#include <initializer_list>

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
         */
        explicit fact_resolver(std::initializer_list<std::string> const& names) :
            _names(names.begin(), names.end()),
            _resolving(false)
        {
        }

        /**
         * Destructs the fact_resolver.
         */
        virtual ~fact_resolver() {}

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
        std::vector<std::string> const& names() { return _names; }

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        void resolve(fact_map& facts);

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts) = 0;

     private:
        std::vector<std::string> _names;
        bool _resolving;
    };

}}  // namespace cfacter::facts

#endif  // LIB_INC_FACTS_FACT_RESOLVER_HPP_

