/**
* @file
* Declares the Facter Ruby functions.
*/
#pragma once

#include "../facts/collection.hpp"
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
     * @param paths The paths to search for custom facts.
     */
    LIBFACTER_EXPORT void load_custom_facts(facter::facts::collection& facts, std::vector<std::string> const& paths = {});

}}  // namespace facter::ruby
