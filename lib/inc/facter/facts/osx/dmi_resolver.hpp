#ifndef FACTER_FACTS_OSX_DMI_RESOLVER_HPP_
#define FACTER_FACTS_OSX_DMI_RESOLVER_HPP_

#include "../posix/dmi_resolver.hpp"

namespace facter { namespace facts { namespace osx {

    /**
     * Responsible for resolving DMI facts.
     */
    struct dmi_resolver : posix::dmi_resolver
    {
     protected:
        /**
         * Called to resolve all facts the resolver is responsible for.
         * @param facts The fact map that is resolving facts.
         */
        virtual void resolve_facts(fact_map& facts);

     private:
        void resolve_product_name(fact_map& facts);
    };

}}}  // namespace facter::facts::osx

#endif  // FACTER_FACTS_OSX_DMI_RESOLVER_HPP_

