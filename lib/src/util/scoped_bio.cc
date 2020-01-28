#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <internal/util/scoped_bio.hpp>

using namespace std;
using namespace leatherman::util;

namespace facter { namespace util {

    // Remove const-ness before calling BIO_new. This is "unsafe",
    // but in isolation here will not cause issues. Allows the code to work
    // with both OpenSSL 1.0 and 1.1.
    scoped_bio::scoped_bio(const BIO_METHOD* method) :
        scoped_resource(BIO_new(const_cast<BIO_METHOD*>(method)), free)
    {
    }

    scoped_bio::scoped_bio(BIO* bio) :
        scoped_resource(move(bio), free)
    {
    }

    void scoped_bio::free(BIO* bio)
    {
        if (bio) {
            BIO_free(bio);
        }
    }

}}  // namespace facter::util
