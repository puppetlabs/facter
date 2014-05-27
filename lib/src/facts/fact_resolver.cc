#include <facter/facts/fact_resolver.hpp>
#include <facter/facts/fact_map.hpp>
#include <facter/logging/logging.hpp>
#include <re2/re2.h>

using namespace std;
using namespace re2;

LOG_DECLARE_NAMESPACE("facts.resolver");

namespace facter { namespace facts {

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

    circular_resolution_exception::circular_resolution_exception(string const& message) :
        runtime_error(message)
    {
    }

    invalid_name_pattern_exception::invalid_name_pattern_exception(string const& message) :
        runtime_error(message)
    {
    }

    fact_resolver::fact_resolver(string&& name, vector<string>&& names, vector<string> const& patterns) :
        _name(move(name)),
        _names(move(names)),
        _resolving(false)
    {
        for (auto const& pattern : patterns) {
            auto regex = unique_ptr<RE2>(new RE2(pattern));
            if (!regex->error().empty()) {
                throw invalid_name_pattern_exception(regex->error());
            }
            _regexes.push_back(move(regex));
        }
    }

    fact_resolver::~fact_resolver()
    {
        // This needs to be defined here since we use incomplete types in the header
    }

    string const& fact_resolver::name() const
    {
        return _name;
    }

    vector<string> const& fact_resolver::names() const
    {
        return _names;
    }

    void fact_resolver::resolve(fact_map& facts)
    {
        LOG_DEBUG("resolving %1% facts.", _name);
        if (_resolving) {
            throw circular_resolution_exception("a cycle in fact resolution was detected.");
        }
        cycle_guard guard(_resolving);
        return resolve_facts(facts);
    }

    bool fact_resolver::can_resolve(string const& name) const
    {
        // Check to see if any of our regexes match
        for (auto const& regex : _regexes) {
            if (RE2::PartialMatch(name, *regex)) {
                return true;
            }
        }
        return false;
    }

}}  // namespace facter::facts
