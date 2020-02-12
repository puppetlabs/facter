#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#include <catch.hpp>
#include <internal/util/scoped_bio.hpp>
#include <openssl/evp.h>

using namespace std;
using namespace facter::util;

SCENARIO("constructing a scoped_bio") {
    scoped_bio b64((BIO_f_base64()));
    REQUIRE(static_cast<BIO*>(b64));
}
