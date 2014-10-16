#include <facter/facts/resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/regex.hpp>

using namespace std;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.resolver"

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

    resolver::resolver(string name, vector<string> names, vector<string> const& patterns) :
        _name(move(name)),
        _names(move(names)),
        _resolving(false)
    {
        for (auto const& pattern : patterns) {
            auto regex = unique_ptr<util::re_adapter>(new util::re_adapter(pattern));
            if (!regex->error().empty()) {
                throw invalid_name_pattern_exception(regex->error());
            }
            _regexes.push_back(std::move(regex));
        }
    }

    resolver::~resolver()
    {
        // This needs to be defined here since we use incomplete types in the header
    }

    resolver::resolver(resolver&& other)
    {
        *this = std::move(other);
    }

    resolver& resolver::operator=(resolver&& other)
    {
        if (this != &other) {
            _name = std::move(other._name);
            _names = std::move(other._names);
            _regexes = std::move(other._regexes);
            _resolving = std::move(other._resolving);
        }
        return *this;
    }

    string const& resolver::name() const
    {
        return _name;
    }

    vector<string> const& resolver::names() const
    {
        return _names;
    }

    bool resolver::has_patterns() const
    {
        return _regexes.size() > 0;
    }

    bool resolver::is_match(string const& name) const
    {
        // Check to see if any of our regexes match
        for (auto const& regex : _regexes) {
            if (re_search(name, *regex)) {
                return true;
            }
        }
        return false;
    }

    void resolver::resolve(collection& facts)
    {
        LOG_DEBUG("resolving %1% facts.", _name);
        if (_resolving) {
            throw circular_resolution_exception("a cycle in fact resolution was detected.");
        }
        cycle_guard guard(_resolving);
        resolve_facts(facts);
    }

}}  // namespace facter::facts
