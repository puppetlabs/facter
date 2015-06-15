/**
 * @file
 * Declares utility functions parsing version strings.
 */
#pragma once

#include <string>
#include <tuple>

namespace facter { namespace util { namespace version_parsing {

    /**
     * Parses the major and minor kernel versions for all platforms except Linux.
     * @param version The version to parse.
     * @return Returns a tuple of major and minor versions.
     */
    std::tuple<std::string, std::string> parse_kernel_version(std::string const& version);

    /**
     * Parses the major and minor kernel versions for Linux platforms
     * @param version The version to parse.
     * @return Returns a tuple of major and minor versions.
     */
    std::tuple<std::string, std::string> parse_linux_kernel_version(std::string const& version);

}}}  // namespace facter::util::version_parsing
