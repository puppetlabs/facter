/**
 * @file
 * Declares the virtual machine name constants.
 */
#ifndef FACTER_FACTS_VIRTUAL_MACHINE_HPP_
#define FACTER_FACTS_VIRTUAL_MACHINE_HPP_

namespace facter { namespace facts {

    /**
     * Stores the constant virtual machine names.
     */
    struct vm
    {
        /**
         * The name for VMWare virtual machine.
         */
        constexpr static char const* vmware = "vmware";

        /**
         * The name for VirtualBox virtual machine.
         */
        constexpr static char const* virtualbox = "virtualbox";

        /**
         * The name for Parallels virtual machine.
         */
        constexpr static char const* parallels = "parallels";
    };

}}  // namespace facter::facts

#endif  // FACTER_FACTS_VIRTUAL_MACHINE_HPP_
