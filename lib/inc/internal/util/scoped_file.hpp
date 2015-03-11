/**
 * @file
 * Declares the scoped file resource for managing FILE pointers.
 */
#pragma once

#include <facter/util/scoped_resource.hpp>
#include <string>
#include <cstdio>

namespace facter { namespace util {

    /**
     * Represents a scoped file.
     * Automatically closes the file when it goes out of scope.
    */
    struct scoped_file : scoped_resource<std::FILE*>
    {
        /**
         * Constructs a scoped_file.
         * @param path The path to the file.
         * @param mode The open mode.
         */
        explicit scoped_file(std::string const& path, std::string const& mode);

        /**
         * Constructs a scoped_file.
         * @param file The existing file pointer.
         */
        explicit scoped_file(std::FILE* file);

     private:
        static void close(std::FILE* file);
    };

}}  // namespace facter::util
