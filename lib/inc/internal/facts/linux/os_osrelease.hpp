/**
 * @file
 * Declares the Linux operating system query helper based on /etc/os-release.
 */
#pragma once

#include <internal/facts/linux/os_linux.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/os_family.hpp>
#include <iostream>
using namespace std;

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for determining the name/family/release of Freedesktop-compliant operating systems.
     */
    struct os_osrelease : os_linux
    {
        /**
         * Constructs os_release based on details from /etc/os-release.
         */
        os_osrelease() : os_linux({"ID", "VERSION_ID"}) {}

        /**
         * Returns the release name based on the ID field from /etc/os-release
         * (which has fewer variations to check for than the NAME field)
         * @param distro_id Unused.
         * @return Returns the OS name.
         */
        virtual std::string get_name(std::string const& distro_id) const override
        {
            auto val = _release_info.find("ID");
            if (val != _release_info.end()) {
                auto& id = val->second;

                if (id == "coreos") {
                    return os::coreos;
                } else if (id == "cumulus-linux") {
                    return os::cumulus;
                } else if (id == "opensuse" || id == "opensuse-leap") {
                    return os::open_suse;
                } else if (id == "sled") {
                    return os::suse_enterprise_desktop;
                } else if (id == "sles") {
                    return os::suse_enterprise_server;
                }
            }
            return std::string();
        }

        /**
         * Returns the release family based on the ID field from /etc/os-release
         * (which has fewer variations to check for than the NAME field)
         * @param name Unused.
         * @return Returns the OS family.
         */
        virtual std::string get_family(std::string const& name) const override
        {
            auto val = _release_info.find("ID");
            if (val != _release_info.end()) {
                auto& id = val->second;

                if (id == "coreos") {
                    return os_family::coreos;
                } else if (id == "cumulus-linux") {
                    return os_family::debian;
                } else if (id == "opensuse" || id == "opensuse-leap" || id == "sled" || id == "sles") {
                    return os_family::suse;
                }
            }
            return std::string();
        }

        /**
         * Returns the OS release version based on the VERSION_ID field from /etc/os-release.
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
