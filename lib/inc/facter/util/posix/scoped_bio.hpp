#ifndef FACTER_UTIL_POSIX_SCOPED_BIO_HPP_
#define FACTER_UTIL_POSIX_SCOPED_BIO_HPP_

#include "../scoped_resource.hpp"
#include <openssl/bio.h>

namespace facter { namespace util { namespace posix {

    /**
     * Represents a scoped OpenSSL BIO object.
     * Automatically frees the BIO when it goes out of scope.
    */
    struct scoped_bio : scoped_resource<BIO*>
    {
        /**
         * Constructs a scoped_bio.
         * @param method The BIO_METHOD to use.
         */
        explicit scoped_bio(BIO_METHOD* method) :
            scoped_resource(BIO_new(method), free)
        {
        }

        /**
         * Constructs a scoped_bio.
         * @param bio The BIO to free when destroyed.
         */
        explicit scoped_bio(BIO* bio) :
            scoped_resource(std::move(bio), free)
        {
        }

     private:
        static void free(BIO* bio)
        {
            if (bio) {
                BIO_free(bio);
            }
        }
    };

}}}  // namespace facter::util::posix

#endif  // FACTER_UTIL_POSIX_SCOPED_BIO_HPP_
