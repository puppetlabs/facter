#include <facter/facts/resolver.hpp>
#include <facter/facts/collection.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/util/environment.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/locale/info.hpp>

using namespace std;
using namespace leatherman::util;

namespace facter { namespace facts {

    invalid_name_pattern_exception::invalid_name_pattern_exception(string const& message) :
        runtime_error(message)
    {
    }

    resolver::resolver(string name, vector<string> names, vector<string> const& patterns) :
        _name(move(name)),
        _names(move(names))
    {
        for (auto const& pattern : patterns) {
            try {
                _regexes.push_back(boost::regex(pattern));
            } catch (boost::regex_error const& ex) {
                throw invalid_name_pattern_exception(ex.what());
            }
        }
    }

    void resolver::log_fact_blockage(string fact_name) {
        LOG_DEBUG("collection of %1% fact has been blocked", fact_name);
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
            _http_langs = std::move(other._http_langs);
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
            if (re_search(name, regex)) {
                return true;
            }
        }
        return false;
    }

    string const& resolver::http_langs()
    {
#ifdef LEATHERMAN_USE_LOCALES
        if (_http_langs.empty()) {
            // build Accept-Language list for HTTP-based resolvers
            const auto& loc = leatherman::locale::get_locale();
            if (std::has_facet<boost::locale::info>(loc)) {
                const auto& info = std::use_facet<boost::locale::info>(loc);
                string lang = info.language();
                // use country code when available; add fallback to base lang
                if (!info.country().empty())
                    lang += "-" + info.country() + ", " + info.language();
                // always include English (en) as a fallback
                if (info.language() != "en")
                    lang += ", en";
                std::transform(lang.begin(), lang.end(), lang.begin(), ::tolower);
                _http_langs = lang;
            }
        }
#endif
        return _http_langs;
    }

}}  // namespace facter::facts
