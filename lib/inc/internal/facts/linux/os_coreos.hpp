/**
 * @file
 * Declares the CoreOS Linux operating system query helper.
 */
#pragma once

#include <internal/facts/linux/os_linux.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/os_family.hpp>

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for determining the name/family/release of CoreOS operating systems.
     */
    struct os_coreos : os_linux
    {
        /**
         * Constructs the os_cumulus and reads /etc/os-release to gather relevant details.
         */
        os_coreos() : os_linux({"VERSION_ID"}) {}

        /**
         * Returns the release name.
         * @param distro_id Unused.
         * @return Returns "CoreOS".
         */
        virtual std::string get_name(std::string const& distro_id) const override
        {
            return os::coreos;
        }

        /**
         * Returns the release family.
         * @param name Unused.
         * @return Returns "CoreOS".
         */
        virtual std::string get_family(std::string const& name) const override
        {
            return os_family::coreos;
        }

        /**
         * Finds VERSION_ID from the release file contents and returns it as the release.
         * @param name Unused.
         * @param distro_release Unused.
         * @return Returns the release version.
         */
        virtual std::string get_release(std::string const& name, std::string const& distro_release) const override
        {
            auto val = _release_info.find("VERSION_ID");
            return (val != _release_info.end()) ? val->second : std::string();
        }
    };

}}}  // namespace facter::facts::linux
