/**
 * @file
 * Declares the scoped environment resource for temporarily changing the processes
 * environment and restoring it when the object goes out of scope.
 */
#pragma once

#include "scoped_resource.hpp"
#include <string>
#include <boost/optional.hpp>

namespace facter { namespace util {
    /**
     * This is an RAII wrapper for restoring the environment on Windows.
     * It sets the environment on construction, and restores it on deletion.
     */
    struct scoped_env : scoped_resource<std::tuple<std::string, boost::optional<std::string>>>
    {
        /**
         * Constructs a scoped_env from the specified error code.
         * @param var    The environment variable to update.
         * @param newval The value to set it to during existence of this object.
         */
        explicit scoped_env(std::string var, std::string const& newval);

     private:
        static void restore(std::tuple<std::string, boost::optional<std::string>> &);
    };
}}  // namespace facter::util
