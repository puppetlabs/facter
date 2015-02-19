#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <catch.hpp>
#include <facter/util/posix/scoped_bio.hpp>
#include <openssl/evp.h>

using namespace std;
using namespace facter::util::posix;

SCENARIO("constructing a scoped_bio") {
    scoped_bio b64((BIO_f_base64()));
    REQUIRE(static_cast<BIO*>(b64));
}
