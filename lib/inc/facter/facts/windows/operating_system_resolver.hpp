/**
 * @file
 * Declares the Windows operating system fact resolver.
 */
#pragma once

#include "../resolvers/operating_system_resolver.hpp"
#include <facter/util/windows/wmi.hpp>
#include <memory>

namespace facter { namespace facts { namespace windows {

    /**
     * Responsible for resolving operating system facts.
     */
    struct operating_system_resolver : resolvers::operating_system_resolver
    {
        /**
         * Constructs the operating_system_resolver.
         * @param wmi_conn The WMI connection to use when resolving facts.
         */
        operating_system_resolver(std::shared_ptr<util::windows::wmi> wmi_conn = std::make_shared<util::windows::wmi>());

     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;

        /**
         * Returns the major release version on Windows; it has no consistent minor release naming scheme.
         * @param name The name of the OS.
         * @param release The release to parse.
         * @return Returns a tuple of major and minor release versions.
         */
        virtual std::tuple<std::string, std::string> parse_release(std::string const& name, std::string const& release) const;

     private:
        std::shared_ptr<util::windows::wmi> _wmi;
    };

}}}  // namespace facter::facts::windows
