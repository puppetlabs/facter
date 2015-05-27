/**
 * @file
 * Declares the generic Linux operating system query helper.
 */
#pragma once

#include <internal/facts/linux/release_file.hpp>
#include <set>
#include <map>

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for determining the name/family/release of common operating systems.
     */
    struct os_linux
    {
        /**
         * Constructs the os_linux.
         * @param items Items to read from the release file; used by inheriting classes.
         * @param file The release file to read for OS data; used by inheriting classes.
         */
        os_linux(std::set<std::string> items = {}, std::string file = release_file::os);

        /**
         * Returns the name of the operating system.
         * @param distro_id The distro ID; can be queried as the "Distributor ID" given by lsb_release.
         * @return Returns the release name.
         */
        virtual std::string get_name(std::string const& distro_id) const;

        /**
         * Returns the family of the operating system.
         * @param name The release name determined using get_name.
         * @return Returns the release family.
         */
        virtual std::string get_family(std::string const& name) const;

        /**
         * Returns the release of the operating system.
         * @param name The release name determined using get_name.
         * @param distro_release The distro release; can be queried as the "Release" given by lsb_release.
         * @return Returns the release version.
         */
        virtual std::string get_release(std::string const& name, std::string const& distro_release) const;

        /**
         * Parses a file containing key-value pairs separated by an equal (=) sign, one pair per line.
         * @param file The file to parse.
         * @param items The keys to save from the file. Only keys given in this parameter will be returned.
         * @return The key-value pairs identified in the items argument and found in the file.
         */
        static std::map<std::string, std::string> key_value_file(std::string file, std::set<std::string> const& items);

     protected:
        /**
         * A map of key-value pairs read from the release file.
         */
        std::map<std::string, std::string> _release_info;
    };

}}}  // namespace facter::facts::linux
