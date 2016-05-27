/**
 * @file
 * Declares the FreeBSD Desktop Management Interface (DMI) fact resolver.
 */
#pragma once

#include "../resolvers/dmi_resolver.hpp"

namespace facter { namespace facts { namespace freebsd {

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

     private:
        static std::string kenv_lookup(const char* file);
    };

}}}  // namespace facter::facts::freebsd
