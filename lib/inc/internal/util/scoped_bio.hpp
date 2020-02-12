/**
 * @file
 * Declares the scoped BIO (OpenSSL) resource.
 */
#pragma once

#include <leatherman/util/scoped_resource.hpp>
#include <openssl/bio.h>

namespace facter { namespace util {

    /**
     * Represents a scoped OpenSSL BIO object.
     * Automatically frees the BIO when it goes out of scope.
    */
    struct scoped_bio : leatherman::util::scoped_resource<BIO*>
    {
        /**
         * Constructs a scoped_bio.
         * @param method The BIO_METHOD to use.
         */
        explicit scoped_bio(const BIO_METHOD* method);

        /**
         * Constructs a scoped_bio.
         * @param bio The BIO to free when destroyed.
         */
        explicit scoped_bio(BIO* bio);

     private:
        static void free(BIO* bio);
    };

}}  // namespace facter::util
