#ifndef FACTER_FACTS_LINUX_DMI_RESOLVER_HPP_
#define FACTER_FACTS_LINUX_DMI_RESOLVER_HPP_

#include "../posix/dmi_resolver.hpp"
#include <string>

namespace facter { namespace facts { namespace linux {

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
        static std::string get_chassis_description(std::string const& type);
    };

}}}  // namespace facter::facts::linux

#endif  // FACTER_FACTS_LINUX_DMI_RESOLVER_HPP_

