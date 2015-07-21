/**
 * @file
 * Declares the scoped addrinfo resource.
 */
#pragma once

#include <leatherman/util/scoped_resource.hpp>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string>
#include <cstring>

namespace facter { namespace util { namespace posix {

    /**
     * Represents a scoped addrinfo for POSIX systems.
     * Automatically frees the address information pointer when it goes out of scope.
    */
    struct scoped_addrinfo : leatherman::util::scoped_resource<addrinfo*>
    {
        /**
         * Constructs a scoped_addrinfo.
         * @param hostname The hostname to get the address information of.
         */
        explicit scoped_addrinfo(std::string const& hostname);

        /**
         * Constructs a scoped_addrinfo.
         * @param info The address info to free when destroyed.
         */
        explicit scoped_addrinfo(addrinfo* info);

        /**
         * Returns the result of any call to getaddrinfo.
         * @returns Returns the result of any call to getaddrinfo.
         */
        int result() const;

     private:
        static void free(addrinfo* info);
        int _result;
    };

}}}  // namespace facter::util::posix
