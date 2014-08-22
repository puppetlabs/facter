/**
 * @file
 * Declares the utility functions for parsing and manipulating strings.
 */
#ifndef FACTER_UTIL_STRING_HPP_
#define FACTER_UTIL_STRING_HPP_

#include <string>
#include <vector>
#include <functional>
#include <initializer_list>
#include <cctype>
#include <cstdint>

namespace facter { namespace util {

    /**
     * Checks if the given string starts with the given prefix.
     * @param str The string to check against.
     * @param prefix The prefix to check with.
     * @return Returns true if the given string starts with the given prefix or false if otherwise.
     */
    bool starts_with(std::string const& str, std::string const& prefix);

    /**
     * Checks if the given string ends with the given suffix.
     * @param str The string to check against.
     * @param suffix The suffix to check with.
     * @return Returns true if the given string ends with the given suffix or false if otherwise.
     */
    bool ends_with(std::string const& str, std::string const& suffix);

    /**
     * Represents the default set of characters to trim for the string trimming functions.
     * By default, all whitespace characters are trimmed.
     */
    extern std::initializer_list<char> default_trim_set;

    /**
     * In-place trims characters from the start (left side) of a string.
     * @param str The string to trim characters from.
     * @param set The set of characters to trim.  Defaults to whitespace characters.
     * @return Returns the given string.
     */
    std::string& ltrim(std::string& str, std::initializer_list<char> const& set = default_trim_set);
    /**
     * In-place trims characters from the start (left side) of a string.
     * @param str The string to trim characters from.
     * @param set The set of characters to trim.  Defaults to whitespace characters.
     * @return Returns the given string.
     */
    std::string&& ltrim(std::string&& str, std::initializer_list<char> const& set = default_trim_set);

    /**
     * In-place trims characters from the end (right side) of a string.
     * @param str The string to trim characters from.
     * @param set The set of characters to trim.  Defaults to whitespace characters.
     * @return Returns the given string.
     */
    std::string& rtrim(std::string& str, std::initializer_list<char> const& set = default_trim_set);
    /**
     * In-place trims characters from the end (right side) of a string.
     * @param str The string to trim characters from.
     * @param set The set of characters to trim.  Defaults to whitespace characters.
     * @return Returns the given string.
     */
    std::string&& rtrim(std::string&& str, std::initializer_list<char> const& set = default_trim_set);

    /**
     * In-place trims characters from the the start and end (both sides) of a string.
     * @param str The string to trim characters from.
     * @param set The set of characters to trim.  Defaults to whitespace characters.
     * @return Returns the given string.
     */
    std::string& trim(std::string& str, std::initializer_list<char> const& set = default_trim_set);
    /**
     * In-place trims characters from the the start and end (both sides) of a string.
     * @param str The string to trim characters from.
     * @param set The set of characters to trim.  Defaults to whitespace characters.
     * @return Returns the given string.
     */
    std::string&& trim(std::string&& str, std::initializer_list<char> const& set = default_trim_set);

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
     * @param remove_empty True if empty entries should be removed or false if empty entries should be included.
     * @return Returns a vector of parts.
     */
    std::vector<std::string> split(std::string const& str, char delim = ' ', bool remove_empty = true);

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
    std::string&& to_lower(std::string&& str);

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
    std::string&& to_upper(std::string&& str);

    /**
     * Converts the given bytes to a hexadecimal string.
     * @param bytes The pointer to the bytes to convert.
     * @param length The number of bytes to convert.
     * @param uppercase True if the hexadecimal string should be uppercase or false if it should be lowercase.
     * @return Returns the hexadecimal string.
     */
    std::string to_hex(uint8_t const* bytes, size_t length, bool uppercase = false);

    /**
     * Reads each line from the given string.
     * @param s The string to read.
     * @param callback The callback function that is passed each line in the string.
     */
    void each_line(std::string const& s, std::function<bool(std::string&)> callback);

    /**
     * Character trait type for case-insensitive comparisons.
     * Based on Herb Sutter's post: http://www.gotw.ca/gotw/029.htm
     */
    struct ci_char_traits : public std::char_traits<char>
    {
        /**
         * Compares two characters for case-insensitive equality.
         * @param c1 The first character to compare.
         * @param c2 The second character to compare.
         * @return Returns true if the two characters are equal or false if they are not equal.
         */
        static bool eq(char c1, char c2)
        {
            return std::toupper(c1) == std::toupper(c2);
        }

        /**
         * Compares two characters for case-insensitive inequality.
         * @param c1 The first character to compare.
         * @param c2 The second character to compare.
         * @return Returns true if the two characters are not equal or false if they are equal.
         */
        static bool ne(char c1, char c2)
        {
            return std::toupper(c1) != std::toupper(c2);
        }

        /**
         * Compares two characters for case-insensitive "less-than".
         * @param c1 The first character to compare.
         * @param c2 The second character to compare.
         * @return Returns true if the first character is less than the second character or false if not.
         */
        static bool lt(char c1, char c2)
        {
            return std::toupper(c1) < std::toupper(c2);
        }

        /**
         * Case-insensitively compares two strings.
         * @param s1 The first string to compare.
         * @param s2 The second string to compare.
         * @param n The number of characters to compare.
         * @return Returns a negative value if the first string is less than the second string, zero if the two strings are equal, or a positive value if the first string is greater than the second string.
         */
        static int compare(char const* s1, char const* s2, size_t n);

        /**
         * Searches for the first occurrence of a specified character in a range of characters.
         * @param s The string to search.
         * @param n The number of characters to search.
         * @param a The character to search for.
         * @return Returns a pointer to the first occurrence of the specified character in the range if a match is found; otherwise, a null pointer.
         */
        static char const* find(char const* s, int n, char a)
        {
            while (n-- > 0 && std::toupper(*s) != std::toupper(a)) {
                ++s;
            }
            return s;
        }
    };

    /**
     * Represents a case-insensitive string.
     */
    typedef std::basic_string<char, ci_char_traits> ci_string;

    /**
     * Converts a size, in bytes, to a corresponding string using SI-prefixed units.
     * @param size The size in bytes.
     * @return Returns the size in largest SI unit greater than 1 (e.g. 4.05 GiB, 5.20 MiB, etc).
     */
    std::string si_string(uint64_t size);

    /**
     * Converts an amount used to a percentage.
     * @param used The amount used out of the total.
     * @param total The total amount.
     * @return Returns the percentage (e.g. "41.53%"), to two decimal places, as a string.
     */
    std::string percentage(uint64_t used, uint64_t total);

}}  // namespace facter::util

#endif  // FACTER_UTIL_STRING_HPP_
