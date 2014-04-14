#ifndef LIB_INC_UTIL_STRING_HPP_
#define LIB_INC_UTIL_STRING_HPP_

#include <string>
#include <vector>

// TODO: non-standard header
#include "string.h"

namespace cfacter { namespace util {

    /**
     * In-place trims whitespace from the start (left side) of a string.
     * @param str The string to trim whitespace from.
     * @return Returns the given string.
     */
    std::string& ltrim(std::string& str);
    /**
     * In-place trims whitespace from the start (left side) of a string.
     * @param str The string to trim whitespace from.
     * @return Returns the given string.
     */
    std::string& ltrim(std::string&& str);

    /**
     * In-place trims whitespace from the end (right side) of a string.
     * @param str The string to trim whitespace from.
     * @return Returns the given string.
     */
    std::string& rtrim(std::string& str);
    /**
     * In-place trims whitespace from the end (right side) of a string.
     * @param str The string to trim whitespace from.
     * @return Returns the given string.
     */
    std::string& rtrim(std::string&& str);

    /**
     * In-place trims whitespace from the the start and end (both sides) of a string.
     * @param str The string to trim whitespace from.
     * @return Returns the given string.
     */
    std::string& trim(std::string& str);
    /**
     * In-place trims whitespace from the the start and end (both sides) of a string.
     * @param str The string to trim whitespace from.
     * @return Returns the given string.
     */
    std::string& trim(std::string&& str);

    /**
     * Tokenizes the given string.
     * Tokens are separated by whitespace.
     * @param str The string to tokenize.
     * @return Returns a vector of tokens.
     */
    std::vector<std::string> tokenize(std::string const& str);

    /**
     * Splits a string into parts based on a delimiter.
     * @param str The string to split.
     * @param delim The delimiter to split on.
     * @return Returns a vector of parts.
     */
    std::vector<std::string> split(std::string const& str, char delim = ' ');

    /**
     * Joins a vector of strings together with the given delimiter.
     * @param strings The vector of strings to join.
     * @param delimiter The delimiter to use between strings.
     * @return Returns a string that is the join of the given string.
     */
    std::string join(std::vector<std::string> const& strings, std::string const& delimiter);

    /**
     * Converts the given string to lowercase.
     * @param str The string to convert to lowercase.
     * @return Returns the given string.
     */
    std::string& to_lower(std::string& str);
    /**
     * Converts the given string to lowercase.
     * @param str The string to convert to lowercase.
     * @return Returns the given string.
     */
    std::string& to_lower(std::string&& str);

    /**
     * Converts the given string to uppercase.
     * @param str The string to convert to uppercase.
     * @return Returns the given string.
     */
    std::string& to_upper(std::string& str);
    /**
     * Converts the given string to uppercase.
     * @param str The string to convert to uppercase.
     * @return Returns the given string.
     */
    std::string& to_upper(std::string&& str);

    /**
     * Character trait type for case-insensitive comparisons.
     * Based on Herb Sutter's post: http://www.gotw.ca/gotw/029.htm
     */
    struct ci_char_traits : public std::char_traits<char>
    {
        static bool eq(char c1, char c2)
        {
            return ::toupper(c1) == ::toupper(c2);
        }

        static bool ne(char c1, char c2)
        {
            return ::toupper(c1) != ::toupper(c2);
        }

        static bool lt(char c1, char c2)
        {
            return ::toupper(c1) < ::toupper(c2);
        }

        static int compare(char const* s1, char const* s2, size_t n);

        static char const* find(char const* s, int n, char a)
        {
            while (n-- > 0 && ::toupper(*s) != ::toupper(a)) {
                ++s;
            }
            return s;
        }
    };

    /**
     * Represents a case-insensitive string.
     */
    typedef std::basic_string<char, ci_char_traits> ci_string;

}}  // namespace cfacter::util

#endif  // LIB_INC_UTIL_STRING_HPP_
