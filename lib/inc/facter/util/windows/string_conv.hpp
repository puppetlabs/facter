#pragma once

#include <string>

namespace facter { namespace util { namespace windows {

    /**
     * This is a function for converting UTF-8 strings to UTF-16 wstrings.
     */
    std::wstring to_utf16(std::string const&);

    /**
     * This is a function for converting UTF-16 wstrings to UTF-8 strings.
     */
    std::string to_utf8(std::wstring const&);

}}}  // namespace facter::util::windows
