/**
 * @file
 * Declares the AIX serial number fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace aix {

    /**
     * Responsible for resolving serial number fact.
     */
    struct serial_number_resolver : resolver
    {
         /*
          * Constructs the serial_number_resolver.
          */
         serial_number_resolver();

         /**
          * Called to resolve all the facts the resolver is responsible for.
          * @param facts The fact collection that is resolving facts.
          * @param blocklist A list of facts that should not be collected.
          */
         virtual void resolve(collection& facts, std::set<std::string> const& blocklist) override;
    };
}}}  // namespace facter::facts::aix
