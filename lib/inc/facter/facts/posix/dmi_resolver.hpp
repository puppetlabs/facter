#ifndef FACTER_FACTS_POSIX_DMI_RESOLVER_HPP_
#define FACTER_FACTS_POSIX_DMI_RESOLVER_HPP_

#include "../fact_resolver.hpp"
#include "../fact.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving DMI facts.
     */
    struct dmi_resolver : fact_resolver
    {
        /**
         * Constructs the dmi_resolver.
         */
        dmi_resolver() :
            fact_resolver(
            "desktop management information",
            {
                fact::bios_vendor,
                fact::bios_version,
                fact::bios_release_date,
                fact::board_manufacturer,
                fact::board_product_name,
                fact::board_serial_number,
                fact::manufacturer,
                fact::product_name,
                fact::serial_number,
                fact::product_uuid,
                fact::chassis_type,
            })
        {
        }

     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts) = 0;
    };

}}}  // namespace facter::facts::posix

#endif  // FACTER_FACTS_POSIX_DMI_RESOLVER_HPP_

