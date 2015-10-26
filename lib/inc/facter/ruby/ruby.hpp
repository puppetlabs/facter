/**
* @file
* Declares the Facter Ruby functions.
*/
#pragma once

#include "../facts/collection.hpp"
#include "../facts/value.hpp"
#include "../export.h"
#include <vector>
#include <string>

namespace facter { namespace ruby {

    /**
     * Initialize Ruby integration in Facter.
     * Important: this function must be called in main().
     * Calling this function from an arbitrary stack depth may result in segfaults during Ruby GC.
     * @param include_stack_trace True if Ruby exception messages should include a stack trace or false if not.
     * @return Returns true if Ruby was initialized or false if Ruby could not be initialized (likely not found).
     */
    LIBFACTER_EXPORT bool initialize(bool include_stack_trace = false);

    /**
     * Loads custom facts into the given collection.
     * Important: this function should be called from main().
     * Calling this function from an arbitrary stack depth may result in segfaults during Ruby GC.
     * @param facts The collection to populate with custom facts.
     * @param initialize_puppet Whether puppet should be loaded to find additional facts.
     * @param paths The paths to search for custom facts.
     */
    LIBFACTER_EXPORT void load_custom_facts(facter::facts::collection& facts, bool initialize_puppet, std::vector<std::string> const& paths = {});

    /**
     * Loads custom facts into the given collection.
     * Important: this function should be called from main().
     * Calling this function from an arbitrary stack depth may result in segfaults during Ruby GC.
     * This is provided for backwards compatibility.
     * @param facts The collection to populate with custom facts.
     * @param paths The paths to search for custom facts.
     */
    LIBFACTER_EXPORT void load_custom_facts(facter::facts::collection& facts, std::vector<std::string> const& paths = {});

    /**
     * Traverses a ruby fact and returns a new value based on the
     * query segments passed in the range.
     * @param value The original value to query
     * @param segment The beginning of the query segment range
     * @param end The end of the query segment range
     * @return Returns a pointer to the value queried, or nullptr if it does not exist.
     */
    LIBFACTER_EXPORT facts::value const* lookup(facts::value const* value, std::vector<std::string>::iterator segment, std::vector<std::string>::iterator end);

    /**
     * Uninitialize Ruby integration in Facter.
     * This is unneeded if libfacter was loaded from Ruby. If libfacter instead loads Ruby's dynamic library
     * you should call uninitialize before exiting to avoid dynamic library unload ordering issues with
     * destructors and atexit handlers.
     */
    LIBFACTER_EXPORT void uninitialize();

}}  // namespace facter::ruby
