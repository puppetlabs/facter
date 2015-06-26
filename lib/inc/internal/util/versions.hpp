/**
 * @file
 * Defines helpers for parsing various version strings
 */
#pragma once

#include <string>
#include <tuple>

namespace facter { namespace util { namespace versions {
    /**
     * Helper function for parsing X.Y from an arbitrary version
     * string. If there is a .Z component, it will be ignored.
     * @param version the version string to parse
     * @return A tuple of <maj, min>
     */
    inline std::tuple<std::string, std::string> major_minor(const std::string& version)
    {
         std::string major, minor;
         auto pos = version.find('.');
         if (pos != std::string::npos) {
              auto second = version.find('.', pos+1);
              decltype(second) end;
              major = version.substr(0, pos);
              if (second != std::string::npos) {
                   end = second - (pos + 1);
              } else {
                   end = std::string::npos;
              }
              minor = version.substr(pos+1, end);
         }
         return std::make_tuple(std::move(major), std::move(minor));
    }
}}}  // namespace facter::util::versions
