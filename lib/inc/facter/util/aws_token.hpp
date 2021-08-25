/**
 * @file
 * Declares the utility functions for requesting AWS IDMSv2 tokens.
 */
#pragma once

#ifdef USE_CURL
#include <leatherman/curl/client.hpp>

#include "../export.h"

namespace facter { namespace util {
     /**
     * Retrieves the AWS token
     * @param url the URL where the request is made 
     * @param cli the client used to make the request
     * @param lifetime the lifetime of the token
     */
   std::string get_token(std::string const& url, leatherman::curl::client& cli, int const& lifetime);
}}  // namespace facter::util
#endif  // USE_CURL
