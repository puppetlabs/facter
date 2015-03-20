/**
 * @file
 * Declares the Windows processor fact resolver.
 */
#pragma once

#include "../resolvers/processor_resolver.hpp"
#include "../../util/windows/wmi.hpp"
#include <memory>

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving processor-related facts.
     */
    struct processor_resolver : resolvers::processor_resolver
    {
        /**
         * Constructs the processor_resolver.
         * @param wmi_conn The WMI connection to use when resolving facts.
         */
        processor_resolver(std::shared_ptr<util::windows::wmi> wmi_conn = std::make_shared<util::windows::wmi>());

     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;

     private:
        std::shared_ptr<util::windows::wmi> _wmi;
    };

}}}  // namespace facter::facts::windows
