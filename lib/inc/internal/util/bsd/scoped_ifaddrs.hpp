/**
 * @file
 * Declares the scoped ifaddrs resource.
 */
#pragma once

#include <leatherman/util/scoped_resource.hpp>
#include <ifaddrs.h>

namespace facter { namespace util { namespace bsd {

    /**
     * Represents a scoped ifaddrs pointer that automatically is freed when it goes out of scope.
    */
    struct scoped_ifaddrs : leatherman::util::scoped_resource<ifaddrs*>
    {
        /**
         * Default constructor.
         * This constructor will handle calling getifaddrs.
         */
        scoped_ifaddrs();

        /**
         * Constructs a scoped_descriptor.
         * @param addrs The ifaddrs pointer to free when destroyed
         */
        explicit scoped_ifaddrs(ifaddrs* addrs);

     private:
        static void free(ifaddrs* addrs);
    };

}}}  // namespace facter::util::bsd
