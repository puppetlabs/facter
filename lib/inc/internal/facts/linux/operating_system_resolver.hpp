/**
 * @file
 * Declares the Linux operating system fact resolver.
 */
#pragma once

#include "../posix/operating_system_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : posix::operating_system_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;

        /**
         * Parses the major and minor OS release versions.
         * @param name The name of the OS.
         * @param release The release to parse.
         * @return Returns a tuple of major and minor release versions.
         */
        virtual std::tuple<std::string, std::string> parse_release(std::string const& name, std::string const& release) const override;

     private:
        static selinux_data collect_selinux_data();
    };

}}}  // namespace facter::facts::linux
