/**
 * @file
 * Declares the POSIX timezone fact resolver.
 */
#pragma once

#include "../resolvers/timezone_resolver.hpp"

namespace facter { namespace facts { namespace posix {

    /**
     * Responsible for resolving time zone facts.
     */
    struct timezone_resolver : resolvers::timezone_resolver
    {
     protected:
        /**
         * Gets the system timezone.
         * @return Returns the system timezone.
         */
        virtual std::string get_timezone() override;
    };

}}}  // namespace facter::facts::posix
