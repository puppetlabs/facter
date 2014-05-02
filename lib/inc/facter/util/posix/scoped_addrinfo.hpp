#ifndef FACTER_UTIL_POSIX_SCOPED_ADDRINFO_HPP_
#define FACTER_UTIL_POSIX_SCOPED_ADDRINFO_HPP_

#include "../scoped_resource.hpp"
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string>
#include <cstring>

namespace facter { namespace util { namespace posix {

    /**
     * Represents a scoped file descriptor for POSIX systems.
     * Automatically frees the address information pointer when it goes out of scope.
    */
    struct scoped_addrinfo : scoped_resource<addrinfo*>
    {
        /**
         * Constructs a scoped_addrinfo.
         * @param info The address info to free when destroyed.
         */
        explicit scoped_addrinfo(std::string const& hostname)
        {
            addrinfo hints;
            std::memset(&hints, 0, sizeof hints);
            hints.ai_family = AF_UNSPEC;
            hints.ai_socktype = SOCK_STREAM;
            hints.ai_flags = AI_CANONNAME;

            _result = getaddrinfo(hostname.c_str(), nullptr, &hints, &_resource);
            if (_result != 0) {
                _resource = nullptr;
            } else {
                _deleter = free;
            }
        }

        /**
         * Constructs a scoped_addrinfo.
         * @param info The address info to free when destroyed.
         */
        explicit scoped_addrinfo(addrinfo* info) :
            scoped_resource(std::move(info), free),
            _result(0)
        {
        }

        /**
         * Returns the result of any call to getaddrinfo.
         * @returns Returns the result of any call to getaddrinfo.
         */
        int result() const { return _result; }

     private:
        static void free(addrinfo* info)
        {
            if (info) {
                ::freeaddrinfo(info);
            }
        }
        int _result;
    };

}}}  // namespace facter::util::posix

#endif  // FACTER_UTIL_POSIX_SCOPED_ADDRINFO_HPP_
