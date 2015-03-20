/**
 * @file
 * Declares the scoped resource for temporarily changing an environment variable.
 */
#pragma once

#include <facter/util/scoped_resource.hpp>
#include <string>
#include <boost/optional.hpp>

namespace facter { namespace util {

    /**
     * This is an RAII wrapper for temporarily changing an environment variable.
     * It sets the environment on construction and restores it on destruction.
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
