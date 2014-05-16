#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <gmock/gmock.h>
#include <facter/util/posix/scoped_bio.hpp>
#include <openssl/evp.h>

using namespace std;
using namespace facter::util::posix;

TEST(facter_util_posix_scoped_bio, construction) {
    scoped_bio b64((BIO_f_base64()));
    ASSERT_NE(nullptr, static_cast<BIO*>(b64));
}
