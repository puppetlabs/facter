#ifndef FACTER_UTIL_SCOPED_FILE_HPP_
#define FACTER_UTIL_SCOPED_FILE_HPP_

#include "scoped_resource.hpp"
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
        explicit scoped_file(std::string const& path, std::string const& mode) :
            scoped_resource(std::fopen(path.c_str(), mode.c_str()), close)
        {
        }

        /**
         * Constructs a scoped_file.
         * @param file The existing file pointer.
         */
        explicit scoped_file(std::FILE* file) :
            scoped_resource(std::move(file), close)
        {
        }

     private:
        static void close(std::FILE* file)
        {
            if (file) {
                fclose(file);
            }
        }
    };

}}  // namespace facter::util

#endif  // FACTER_UTIL_SCOPED_FILE_HPP_
