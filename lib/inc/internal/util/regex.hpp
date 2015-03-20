/**
 * @file
 * Defines an abstraction for using regular expression calls.
 */
#pragma once

#include <boost/regex.hpp>
#include <boost/lexical_cast.hpp>

namespace facter { namespace util {

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
     * @param pattern The pattern to search the text with.
     * @param args The returned match groups.
     * @return Returns true if the text matches the given pattern or false if it does not.
     */
    template <typename Text, typename... Args>
    inline bool re_search(Text const& txt, boost::regex const& pattern, Args&&... args)
    {
        boost::smatch what;
        if (!boost::regex_search(txt, what, pattern)) {
            return false;
        }

        return re_search_helper(txt, what, 1, std::forward<Args>(args)...);
    }

}}  // namespace facter::util
