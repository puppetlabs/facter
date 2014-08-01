#include <gmock/gmock.h>
#include <facter/ruby/api.hpp>

using namespace facter::ruby;

int main(int argc, char **argv)
{
    // Before running tests, initialize Ruby
    auto ruby = api::instance();
    if (ruby) {
        ruby->initialize();
    }
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
