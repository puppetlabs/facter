/**
* @file
* Declares the base Desktop Management Interface (DMI) fact resolver.
*/
#pragma once

#include <facter/facts/resolver.hpp>
#include <string>

namespace facter { namespace facts { namespace resolvers {

    /**
    * Responsible for resolving DMI facts.
    */
    struct dmi_resolver : resolver
    {
        /**
         * Constructs the dmi_resolver.
         */
        dmi_resolver();

        /**
         * Converts the given chassis type identifier to a description string.
         * @param type The chassis type identifier.
         * @return Returns the chassis description string.
         */
        static std::string to_chassis_description(std::string const& type);

        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact collection that is resolving facts.
         * @param blocklist A list of facts that should not be collected.
         */
        virtual void resolve(collection& facts, std::set<std::string> const& blocklist) override;

     protected:
        /**
         *  Represents DMI data.
         */
        struct data
        {
            /**
             * Stores the BIOS vendor.
             */
            std::string bios_vendor;

            /**
             * Stores the BIOS version.
             */
            std::string bios_version;

            /**
             * Stores the BIOS release date.
             */
            std::string bios_release_date;

            /**
             * Stores the board asset tag.
             */
            std::string board_asset_tag;

            /**
             * Stores the board manufacturer.
             */
            std::string board_manufacturer;

            /**
             * Stores the board product name.
             */
            std::string board_product_name;

            /**
             * Stores the board serial number.
             */
            std::string board_serial_number;

            /**
             * Stores the chassis asset tag.
             */
            std::string chassis_asset_tag;

            /**
             * Stores the system manufacturer.
             */
            std::string manufacturer;

            /**
             *  Stores the system product name.
             */
            std::string product_name;

            /**
             * Stores the system serial number.
             */
            std::string serial_number;

            /**
             * Stores the system product UUID.
             */
            std::string uuid;

            /**
             * Stores the system chassis type.
             */
            std::string chassis_type;
        };

        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns resolver DMI data.
         */
        virtual data collect_data(collection& facts) = 0;
    };

}}}  // namespace facter::facts::resolvers
