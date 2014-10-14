#pragma once

#include <string>
#include <stdexcept>

namespace facter { namespace util { namespace windows {

    /**
     * Exception thrown when string conversion to UTF8 or UTF16 fails.
     */
    struct string_conv_exception : std::runtime_error
    {
        /**
         * Constructs a string_conv_exception.
         * @param message The exception message.
         */
        explicit string_conv_exception(std::string const& message);
    };

    /**
     * This is a function for converting UTF-8 strings to UTF-16 wstrings.
     */
    std::wstring to_utf16(std::string const&);

    /**
     * This is a function for converting UTF-16 wstrings to UTF-8 strings.
     */
    std::string to_utf8(std::wstring const&);

}}}  // namespace facter::util::windows
