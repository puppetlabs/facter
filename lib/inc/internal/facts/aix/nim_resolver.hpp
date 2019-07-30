/**
 * @file
 * Declares the AIX NIM Type fact resolver.
 */
#pragma once

#include <facter/facts/resolver.hpp>

namespace facter { namespace facts { namespace aix {

    /**
     * Responsible for resolving NIM Type fact.
     */
    struct nim_resolver : resolver
    {
         /*
          * Constructs the nim_resolver.
          */
         nim_resolver();

         /**
          * Called to resolve all the facts the resolver is responsible for.
          * @param facts The fact collection that is resolving facts.
          */
         virtual void resolve(collection& facts) override;

         virtual std::string read_niminfo();
    };
}}}  // namespace facter::facts::aix
