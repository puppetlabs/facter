/**
 * @file
 * Declares the Cisco Linux operating system query helper.
 */
#pragma once

#include <internal/facts/linux/os_linux.hpp>

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for determining the name/family/release of Cisco operating systems.
     */
    struct os_cisco : os_linux
    {
        /**
         * Constructs the os_cisco and reads a release file to gather relevant details.
         * @param file The release file to read for OS data.
         */
        os_cisco(std::string const& file) : os_linux({"ID", "ID_LIKE", "VERSION"}, file) {}

        /**
         * Finds ID from the release file contents and returns it as the name.
         * @param distro_id Unused.
         * @return Returns the release name.
         */
        virtual std::string get_name(std::string const& distro_id) const override
        {
            auto val = _release_info.find("ID");
            return (val != _release_info.end()) ? val->second : std::string();
        }

        /**
         * Finds ID_LIKE from the release file contents and returns it as the family.
         * @param name Unused.
         * @return Returns the release family.
         */
        virtual std::string get_family(std::string const& name) const override
        {
            auto val = _release_info.find("ID_LIKE");
            return (val != _release_info.end()) ? val->second : std::string();
        }

        /**
         * Finds VERSION from the release file contents and returns it as the release.
         * @param name Unused.
         * @param distro_release Unused.
         * @return Returns the release version.
         */
        virtual std::string get_release(std::string const& name, std::string const& distro_release) const override
        {
            auto val = _release_info.find("VERSION");
            return (val != _release_info.end()) ? val->second : std::string();
        }
    };

}}}  // namespace facter::facts::linux
