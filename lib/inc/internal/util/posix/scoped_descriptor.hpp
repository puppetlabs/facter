/**
 * @file
 * Declares the scoped descriptor resource for managing file/socket descriptors.
 */
#pragma once

#include <facter/util/scoped_resource.hpp>
#include <unistd.h>

namespace facter { namespace util { namespace posix {
    /**
     * Represents a scoped file descriptor for POSIX systems.
     * Automatically closes the file descriptor when it goes out of scope.
    */
    struct scoped_descriptor : scoped_resource<int>
    {
        /**
         * Constructs a scoped_descriptor.
         * @param descriptor The file descriptor to close when destroyed.
         */
        explicit scoped_descriptor(int descriptor);

     private:
        static void close(int descriptor);
    };

}}}  // namespace facter::util::posix
