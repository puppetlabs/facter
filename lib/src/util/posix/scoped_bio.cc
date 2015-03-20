#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <internal/util/posix/scoped_bio.hpp>

using namespace std;

namespace facter { namespace util { namespace posix {

    scoped_bio::scoped_bio(BIO_METHOD* method) :
        scoped_resource(BIO_new(method), free)
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

}}}  // namespace facter::util::posix
