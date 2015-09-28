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
          */
         virtual void resolve(collection& facts) override;
    };
}}}  // namespace facter::facts::aix
