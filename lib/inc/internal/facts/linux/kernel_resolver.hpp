/**
 * @file
 * Declares the Linux kernel fact resolver.
 */
#pragma once

#include "../posix/kernel_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving kernel facts.
     */
    struct kernel_resolver : posix::kernel_resolver
    {
     protected:
        /**
         * Parses the major and minor kernel versions.
         * @param version The version to parse.
         * @return Returns a tuple of major and minor versions.
         */
        std::tuple<std::string, std::string> parse_version(std::string const& version) const override;
    };

}}}  // namespace facter::facts::linux
