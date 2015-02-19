/**
 * @file
 * Declares utility functions for reading data from files.
 */
#pragma once

#include <string>
#include <stdexcept>
#include <functional>

namespace facter { namespace util {

    /**
     * Contains utility functions for reading data from files.
     */
    struct file
    {
        /**
         * Reads each line from the given file.
         * @param path The path to the file to read.
         * @param callback The callback function that is passed each line in the file.
         * @return Returns true if the file was opened successfully or false if it was not.
         */
        static bool each_line(std::string const& path, std::function<bool(std::string&)> callback);

        /**
         * Reads the entire contents of the given file into a string.
         * @param path The path of the file to read.
         * @return Returns the file contents as a string.
         */
        static std::string read(std::string const& path);

        /**
         * Reads the entire contents of the given file into a string.
         * @param path The path of the file to read.
         * @param contents The returned file contents.
         * @return Returns true if the contents were read or false if the file is not readable.
         */
        static bool read(std::string const& path, std::string& contents);
    };

}}  // namespace facter::util
