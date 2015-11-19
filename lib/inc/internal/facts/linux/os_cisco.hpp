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
         * @param file The release file to read for Cisco-specific OS data.
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
            /*
             * This benefits from some explanation.
             * Some Cisco platforms have multiple runtime environments.
             * For these platforms, the name reports as the same regardless of
             * the environment (e.g., "nexus"), but we want the family to report
             * appropriately according to the environment (e.g., "cisco-wrlinux"
             * versus "RedHat").
             *
             * In order to achieve this goal, we first check to see what would
             * be reported if we were a standard Linux environment (e.g., a
             * Linux distro that detects its name as "centos" would map to
             * family "RedHat"). Only if a standard Linux family is not
             * detected do we fall back on the information given in our Cisco
             * release info file.
             */
            auto value = os_linux::get_family(os_linux::get_name(""));
            if (!value.empty()) {
                return value;
            }
            auto val = _release_info.find("ID_LIKE");
            if (val != _release_info.end()) {
                auto& family = val->second;
                auto pos = family.find(" ");
                // If multiple values are found in ID_LIKE, only return the
                // first one (FACT-1246)
                if (pos != std::string::npos) {
                    return family.substr(0, pos);
                }
                return family;
            }
            return std::string();
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

        /**
         * Parses the release version string to return the major version.
         * @param name Unused.
         * @param release The release version determined using get_release.
         * @return Returns a tuple of the major and minor versions.
         */
        virtual std::tuple<std::string, std::string> parse_release(std::string const& name, std::string const& release) const override
        {
            /*
             * Cisco software versions can be idiosyncratic.
             * NX-OS looks something like '7.0(3)I2(0.455)'
             * IOS XR looks something like '6.0.0.06I'
             */
            auto pos = release.find('.');
            if (pos != std::string::npos) {
                auto second = release.find('(', pos + 1);
                if (second == std::string::npos) {
                    second = release.find('.', pos + 1);
                }
                if (second == std::string::npos) {
                    return std::make_tuple(release.substr(0, pos), std::string());
                }
                return std::make_tuple(release.substr(0, pos),
                                       release.substr(pos + 1, second - (pos + 1)));
            }
            return std::make_tuple(release, std::string());
        }
    };

}}}  // namespace facter::facts::linux
