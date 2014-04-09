#ifndef __FACT_HPP__
#define	__FACT_HPP__

#include "value.hpp"
#include <map>
#include <memory>
#include <string>

namespace cfacter { namespace facts {

    /**
     * Represents a fact.
     */
    struct fact
    {
        /**
         * Constructs a fact with the given name.
         */
        fact(std::string&& name, std::unique_ptr<value> && value) :
            _name(std::move(name)),
            _value(std::move(value))
        {
        }

        /**
         * Gets the name of the fact.
         * @return Returns the name of the fact.
         */
        std::string const& name() const { return _name; }

        /**
         * Gets the fact's value
         * @return Returns the fact's value.
         */
        value const* val() const { return _value.get(); }

        // Force non-copyable
        fact(fact const&) = delete;
        fact& operator=(fact const&) = delete;

        // Allow movable
        fact(fact&&) = default;
        fact& operator=(fact&&) = default;

    private:
        std::string _name;
        std::unique_ptr<value> _value;
    };

    /**
     * Called to populate all facts.
     */
    void populate_common_facts();
    void populate_platform_facts();

} } // namespace cfacter:facts

#endif

