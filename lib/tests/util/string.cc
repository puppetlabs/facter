#include <gmock/gmock.h>
#include <facter/util/string.hpp>

using namespace std;
using namespace facter::util;
using testing::ElementsAre;

TEST(facter_util_string, to_hex) {
    uint8_t buffer[] = { 0xBA, 0xAD, 0xF0, 0x0D };
    ASSERT_EQ("BAADF00D", to_hex(buffer, sizeof(buffer), true));
    ASSERT_EQ("baadf00d", to_hex(buffer, sizeof(buffer)));
    ASSERT_EQ("", to_hex(nullptr, 0));
    ASSERT_EQ("", to_hex(buffer, 0));
}

TEST(facter_util_string, si_string) {
    ASSERT_EQ("0 bytes", si_string(0));
    ASSERT_EQ("100 bytes", si_string(100));
    ASSERT_EQ("1023 bytes", si_string(1023));
    ASSERT_EQ("1.00 KiB", si_string(1024));
    ASSERT_EQ("4.00 KiB", si_string(4097));
    ASSERT_EQ("1.00 MiB", si_string((1024ull * 1024ull) - 1));
    ASSERT_EQ("1.00 MiB", si_string(1024ull * 1024ull));
    ASSERT_EQ("9.99 MiB", si_string(10ull * 1024ull * 1023ull));
    ASSERT_EQ("1.00 GiB", si_string((1024ull * 1024ull * 1024ull) - 1));
    ASSERT_EQ("1.00 GiB", si_string(1024ull * 1024ull * 1024ull));
    ASSERT_EQ("11.99 GiB", si_string(12ull * 1024ull * 1024ull * 1023ull));
    ASSERT_EQ("1.00 TiB", si_string((1024ull * 1024ull * 1024ull * 1024ull) - 1));
    ASSERT_EQ("1.00 TiB", si_string(1024ull * 1024ull * 1024ull * 1024ull));
    ASSERT_EQ("49.95 TiB", si_string(50ull * 1024ull * 1024ull * 1024ull * 1023ull));
    ASSERT_EQ("1.00 PiB", si_string((1024ull * 1024ull * 1024ull * 1024ull * 1024ull) - 1));
    ASSERT_EQ("1.00 PiB", si_string(1024ull * 1024ull * 1024ull * 1024ull * 1024ull));
    ASSERT_EQ("99.90 PiB", si_string(100ull * 1024ull * 1024ull * 1024ull * 1024ull * 1023ull));
    ASSERT_EQ("1.00 EiB", si_string((1024ull * 1024ull * 1024ull * 1024ull * 1024ull * 1024ull) - 1));
    ASSERT_EQ("1.00 EiB", si_string(1024ull * 1024ull * 1024ull * 1024ull * 1024ull * 1024ull));
    ASSERT_EQ("10.00 EiB", si_string(10ull * 1024ull * 1024ull * 1024ull * 1024ull * 1024ull * 1024ull));
    ASSERT_EQ("16.00 EiB", si_string(numeric_limits<uint64_t>::max()));
}

TEST(fact_util_string, percentage) {
    ASSERT_EQ("100%", percentage(0, 0));
    ASSERT_EQ("0%", percentage(0, 100));
    ASSERT_EQ("1.00%", percentage(1, 100));
    ASSERT_EQ("1.10%", percentage(11, 1000));
    ASSERT_EQ("1.11%", percentage(111, 10000));
    ASSERT_EQ("100%", percentage(1000, 100));
    ASSERT_EQ("99.98%", percentage(99984, 100000));
    ASSERT_EQ("99.99%", percentage(999899, 1000000));
    ASSERT_EQ("99.99%", percentage(99999, 100000));
    ASSERT_EQ("10.00%", percentage(1000, 10000));
    ASSERT_EQ("2.28%", percentage(1140000000ul, 50000000000ul));
    ASSERT_EQ("74.09%", percentage(414906340801ul, 560007030104ul));
    ASSERT_EQ("99.99%", percentage(numeric_limits<uint64_t>::max() - 1, numeric_limits<uint64_t>::max()));
    ASSERT_EQ("100%", percentage(numeric_limits<uint64_t>::max(), numeric_limits<uint64_t>::max()));
}
