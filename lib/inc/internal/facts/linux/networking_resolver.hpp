/**
 * @file
 * Declares the Linux networking fact resolver.
 */
#pragma once

#include "../bsd/networking_resolver.hpp"

namespace facter { namespace facts { namespace linux {

    /**
     * Responsible for resolving networking facts.
     *
     * The Linux networking_resolver inherits from the BSD networking_resolver.
     * This is because getifaddrs is a BSD concept that was implemented in Linux.
     * The only thing this resolver is responsible for is handing link-level
     * addressing and MTU.
     */
    struct networking_resolver : bsd::networking_resolver
    {
     protected:
        /**
         * Collects the resolver data.
         * @param facts The fact collection that is resolving facts.
         * @return Returns the resolver data.
         */
        virtual data collect_data(collection& facts) override;

        /**
         * Determines if the given sock address is a link layer address.
         * @param addr The socket address to check.
         * @returns Returns true if the socket address is a link layer address or false if it is not.
         */
        virtual bool is_link_address(sockaddr const* addr) const override;

        /**
         * Gets the bytes of the link address.
         * @param addr The socket address representing the link address.
         * @return Returns a pointer to the address bytes or nullptr if not a link address.
         */
        virtual uint8_t const* get_link_address_bytes(sockaddr const* addr) const override;

        /**
         * Gets the MTU of the link layer data.
         * @param interface The name of the link layer interface.
         * @param data The data pointer from the link layer interface.
         * @return Returns The MTU of the interface or -1 if there's no MTU.
         */
        virtual boost::optional<uint64_t> get_link_mtu(std::string const& interface, void* data) const override;

        /**
         * Gets the primary interface.
         * This is typically the interface of the default route.
         * @return Returns the primary interface or empty string if one could not be determined.
         */
        virtual std::string get_primary_interface() const override;

     private:
        struct route {
            // In actuality routes are a destination associated with a
            // bunch of key-value pairs, but we only require a couple
            // of those values for our processing of network devices.
            std::string destination;
            std::string interface;
            std::string source;
        };

        void read_routing_table();
        void populate_from_routing_table(data&) const;
        template <typename appender>
        void associate_src_with_iface(const route&, data&, appender) const;
        std::string get_bond_master(const std::string& name) const;

        std::vector<route> routes4;
        std::vector<route> routes6;
    };

}}}  // namespace facter::facts::linux
