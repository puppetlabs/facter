/**
 * @file
 * Defines an abstraction for using regular expression calls.
 * It should be extended when new match methods are needed, and allows easily
 * switching between regex libraries.
 */
#pragma once

#ifdef USE_RE2
#include <re2/re2.h>
#else
// boost includes are not always warning-clean. Disable warnings that
// cause problems before including the headers, then re-enable the warnings.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmaybe-uninitialized"
#include <boost/regex.hpp>
#include <boost/lexical_cast.hpp>
#pragma GCC diagnostic pop
#endif

namespace facter { namespace util {
#ifdef USE_RE2
    using re_adapter = re2::RE2;

    /**
     * Searches the given text for the given pattern.
     * @tparam Args The variadic type of the match group arguments.
     * @param txt The text to search.
     * @param r The pattern to search the text with.
     * @param args The returned match groups.
     * @return Returns true if the text matches the given pattern or false if it does not.
     */
    template <typename... Args>
    inline bool re_search(const re2::StringPiece &txt, const re2::RE2 &r, Args&&... args)
    {
        return re2::RE2::PartialMatch(txt, r, std::forward<Args>(args)...);
    }
#else
    /**
     * Utility class for adapting Boost.Regex.
     */
    class re_adapter : public boost::regex
    {
        std::string _err;
     public:
        /**
         * Constructs a new re_adapter with the given pattern text.
         * @param pattern The regular expression pattern text.
         */
        re_adapter(const char* pattern)
        {
            try {
                assign(pattern);
            } catch (const boost::regex_error &e) {
                _err = e.what();
            }
        }

        /**
         * Constructs a new re_adapter with the given pattern text.
         * @param pattern The regular expression pattern text.
         */
        re_adapter(const std::string &pattern)
        {
            try {
                assign(pattern);
            } catch (const boost::regex_error &e) {
                _err = e.what();
            }
        }

        /**
         * Gets the parse error if there was one.
         * @return Returns the regular expression parse error if there was one.
         */
        const std::string& error() const
        {
            return _err;
        }

        /**
         * Gets whether or not the regular expression has an error.
         * @return Returns true if there was no error or false if there was an error.
         */
        bool ok() const
        {
            return error().empty();
        }
    };

    /**
     * Helper function for resolving variadic arguments to re_search.
     * @tparam Text The type of the text to search.
     * @param txt The text to search.
     * @param what The pattern to search the text with.
     * @param depth The current argument depth.
     * @return Returns true if the match group was found or false if it was not.
     */
    template <typename Text>
    inline bool re_search_helper(Text &txt, const boost::smatch &what, size_t depth)
    {
        return true;
    }

    /**
     * Helper function for resolving variadic arguments to re_search.
     * @tparam Text The type of the text to search.
     * @tparam Arg The type of the current match group argument.
     * @tparam Args The variadic types of the remaining match group arguments.
     * @param txt The text to search.
     * @param what The pattern to search the text with.
     * @param depth The current argument depth.
     * @param arg The current match group argument.
     * @param args The remaining match group arguments.
     * @return Returns true if the match group was found or false if it was not.
     */
    template <typename Text, typename Arg, typename... Args>
    inline bool re_search_helper(Text const& txt, const boost::smatch &what, size_t depth, Arg arg, Args&&... args)
    {
        if (depth >= what.size()) {
            return false;
        }

        // If the match was optional and unmatched, skip it and leave the variable uninitialized.
        if (what[depth].matched) {
            try {
                using ArgType = typename std::pointer_traits<Arg>::element_type;
                auto val = boost::lexical_cast<ArgType>(what[depth]);
                *arg = val;
            } catch (const boost::bad_lexical_cast &e) {
                return false;
            }
        }

        return re_search_helper(txt, what, depth+1, std::forward<Args>(args)...);
    }

    /**
     * Searches the given text for the given pattern. Optional variadic arguments return matched
     * subgroups. If a subgroup is optional and unmatched, leaves the argument uninitialized.
     * @tparam Text The type of the text.
     * @tparam Args The variadic type of the match group arguments.
     * @param txt The text to search.
     * @param r The pattern to search the text with.
     * @param args The returned match groups.
     * @return Returns true if the text matches the given pattern or false if it does not.
     */
    template <typename Text, typename... Args>
    inline bool re_search(Text const& txt, const re_adapter &r, Args&&... args)
    {
        if (!r.ok()) {
            return false;
        }

        boost::smatch what;
        if (!boost::regex_search(txt, what, r)) {
            return false;
        }

        return re_search_helper(txt, what, 1, std::forward<Args>(args)...);
    }
#endif

}}  // namespace facter::util
