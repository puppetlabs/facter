#ifndef LIB_INC_UTIL_BSD_SCOPED_IFADDRS_HPP_
#define LIB_INC_UTIL_BSD_SCOPED_IFADDRS_HPP_

#include "../scoped_resource.hpp"
#include <ifaddrs.h>

namespace cfacter { namespace util { namespace bsd {

    /**
     * Represents a scoped ifaddrs pointer that automatically is freed when it goes out of scope.
    */
    struct scoped_ifaddrs : scoped_resource<ifaddrs*>
    {
        /**
         * Default constructor.
         * This constructor will handle calling getifaddrs.
         */
        scoped_ifaddrs()
        {
            // Get the linked list of interfaces
            if (getifaddrs(&_resource) != 0) {
                _resource = nullptr;
            } else {
                _deleter = free;
            }
        }

        /**
         * Constructs a scoped_descriptor.
         * @param descriptor The file descriptor to close when destroyed.
         */
        explicit scoped_ifaddrs(ifaddrs* addrs) :
            scoped_resource(std::move(addrs), free)
        {
        }

     private:
        static void free(ifaddrs* addrs)
        {
            if (addrs) {
                ::freeifaddrs(addrs);
            }
        }
    };

}}}  // namespace cfacter::util::bsd

#endif  // LIB_INC_UTIL_BSD_SCOPED_IFADDRS_HPP_
