/**
 * @file
 * Declares the C interface to the facter library.
 */
#ifndef FACTER_FACTERLIB_H_
#define FACTER_FACTERLIB_H_

#ifdef __cplusplus
#include <cstddef>
#include <cstdint>
#include <cstdbool>
extern "C" {
#else
#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#endif  // __cplusplus

    ///
    /// Gets the facter library version.
    /// @return Returns the facter library version as a string.
    ///
    char const* get_facter_version();

    ///
    /// Loads and resolves all facts.
    /// @param names The comma-delimited list of fact names to resolve.  If null, all facts are resolved.
    ///
    void load_facts(char const* names);

    ///
    /// Clears the facts.
    ///
    void clear_facts();

    ///
    /// Simple structure to store enumeration callbacks.
    ///
    typedef struct _enumeration_callbacks
    {
        ///
        /// Called when a string value is enumerated.
        /// @param name The name of the fact for this value. May be empty if the value is a member of an array.
        /// @param value The value of the string fact.
        ///
        void(*string)(char const* name, char const* value);
        ///
        /// Called when an integer value is enumerated.
        /// @param name The name of the fact for this value. May be empty if the value is a member of an array.
        /// @param value The value of the integer fact.
        ///
        void(*integer)(char const* name, int64_t value);
        ///
        /// Called when a boolean value is enumerated.
        /// @param name The name of the fact for this value. May be empty if the value is a member of an array.
        /// @param value The value of the boolean fact (zero is false, non-zero true).
        ///
        void(*boolean)(char const* name, uint8_t value);
        ///
        /// Called when a double value is enumerated.
        /// @param name The name of the fact for this value. May be empty if the value is a member of an array.
        /// @param value The value of the double fact.
        ///
        void(*dbl)(char const* name, double value);
        ///
        /// Called when an array value has started being enumerated.
        /// @param name The name of the fact for this value. May be empty if the value is a member of an array.
        ///
        void(*array_start)(char const* name);
        ///
        /// Called when an array value has ended enumeration.
        ///
        void(*array_end)();
        ///
        /// Called when a map value has started being enumerated.
        /// @param name The name of the fact for this value. May be empty if the value is a member of an array.
        ///
        void(*map_start)(char const* name);
        ///
        /// Called when a map value has ended enumeration.
        ///
        void(*map_end)();
    } enumeration_callbacks;

    ///
    /// Enumerates all facts.
    /// @param callbacks The callback functions to use.
    ///
    void enumerate_facts(enumeration_callbacks* callbacks);

    ///
    /// Gets the value of a single fact.
    /// @param name The fact name to get the value of.
    /// @param callbacks The callback functions to use.
    /// @return Returns true if the fact exists or false if the fact does not.
    ///
    bool get_fact_value(char const* name, enumeration_callbacks* callbacks);

    ///
    /// Searches the given directories for external facts.
    /// @param directories The directories to search for external facts.
    ///
    void search_external(char const* directories);

#ifdef __cplusplus
}
#endif  // __cplusplus

#endif  // FACTER_FACTERLIB_H_
