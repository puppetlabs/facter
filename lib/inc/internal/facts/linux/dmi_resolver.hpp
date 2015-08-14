/**
 * @file
 * Declares the Linux Desktop Management Information (DMI) fact resolver.
 */
#pragma once

#include "../resolvers/dmi_resolver.hpp"
#include <string>

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving DMI facts.
     */
    struct dmi_resolver : resolvers::dmi_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;

        /**
         * Parses the output of dmidecode.
         * @param result The resulting data.
         * @param line The line to parse.
         * @param dmi_type The current DMI header type.
         */
        static void parse_dmidecode_output(data& result, std::string& line, int& dmi_type);

    private:
        std::string read(std::string const& path);
    };

}}}  // namespace facter::facts::linux
