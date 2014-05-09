#include <gmock/gmock.h>
#include <facter/util/option_set.hpp>

using namespace std;
using namespace facter::util;

enum class options
{
    foo = (1 << 1),
    bar = (1 << 2),
    baz = (1 << 3)
};

TEST(facter_util_option_set, construction) {
    option_set<options> s1;
    ASSERT_EQ(0u, s1.count());
    ASSERT_FALSE(s1[options::foo]);
    ASSERT_FALSE(s1[options::bar]);
    ASSERT_FALSE(s1[options::baz]);

    option_set<options> s2 = { options::foo };
    ASSERT_EQ(1u, s2.count());
    ASSERT_TRUE(s2[options::foo]);
    ASSERT_FALSE(s2[options::bar]);
    ASSERT_FALSE(s2[options::baz]);

    option_set<options> s3 = { options::bar, options::foo };
    ASSERT_EQ(2u, s3.count());
    ASSERT_TRUE(s3[options::foo]);
    ASSERT_TRUE(s3[options::bar]);
    ASSERT_FALSE(s3[options::baz]);

    option_set<options> s4 = { options::baz, options::foo, options::bar };
    ASSERT_EQ(3u, s4.count());
    ASSERT_TRUE(s4[options::foo]);
    ASSERT_TRUE(s4[options::bar]);
    ASSERT_TRUE(s4[options::baz]);

    option_set<options> s5(1 | 2 | 4);
    ASSERT_EQ(3u, s4.count());
    ASSERT_TRUE(s4[options::foo]);
    ASSERT_TRUE(s4[options::bar]);
    ASSERT_TRUE(s4[options::baz]);
}

TEST(facter_util_option_set, set_all) {
    option_set<options> s;
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);

    s.set_all();
    ASSERT_EQ(s.size(), s.count());
    ASSERT_TRUE(s[options::foo]);
    ASSERT_TRUE(s[options::bar]);
    ASSERT_TRUE(s[options::baz]);
}

TEST(facter_util_option_set, set) {
    option_set<options> s;
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);

    s.set(options::foo);
    ASSERT_EQ(1u, s.count());
    ASSERT_TRUE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);

    s.set(options::bar);
    ASSERT_EQ(2u, s.count());
    ASSERT_TRUE(s[options::foo]);
    ASSERT_TRUE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);

    s.set(options::baz);
    ASSERT_EQ(3u, s.count());
    ASSERT_TRUE(s[options::foo]);
    ASSERT_TRUE(s[options::bar]);
    ASSERT_TRUE(s[options::baz]);
}

TEST(facter_util_option_set, clear) {
    option_set<options> s = { options::foo, options::bar, options::baz };
    ASSERT_EQ(3u, s.count());
    ASSERT_TRUE(s[options::foo]);
    ASSERT_TRUE(s[options::bar]);
    ASSERT_TRUE(s[options::baz]);

    s.clear(options::foo);
    ASSERT_EQ(2u, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_TRUE(s[options::bar]);
    ASSERT_TRUE(s[options::baz]);

    s.clear(options::bar);
    ASSERT_EQ(1u, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_TRUE(s[options::baz]);

    s.clear(options::baz);
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);
}

TEST(facter_util_option_set, reset) {
    option_set<options> s;
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);

    s.reset();
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);

    s.set(options::foo).set(options::bar).set(options::baz);
    ASSERT_EQ(3u, s.count());
    ASSERT_TRUE(s[options::foo]);
    ASSERT_TRUE(s[options::bar]);
    ASSERT_TRUE(s[options::baz]);

    s.reset();
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);
}

TEST(facter_util_option_set, toggle) {
    option_set<options> s;
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);

    s.toggle();
    ASSERT_EQ(s.size(), s.count());
    ASSERT_TRUE(s[options::foo]);
    ASSERT_TRUE(s[options::bar]);
    ASSERT_TRUE(s[options::baz]);

    s.reset();
    s.set(options::foo).set(options::bar).set(options::baz);
    ASSERT_EQ(3u, s.count());
    ASSERT_TRUE(s[options::foo]);
    ASSERT_TRUE(s[options::bar]);
    ASSERT_TRUE(s[options::baz]);

    s.toggle();
    ASSERT_EQ(s.size() - 3, s.count());
    ASSERT_FALSE(s[options::foo]);
    ASSERT_FALSE(s[options::bar]);
    ASSERT_FALSE(s[options::baz]);
}

TEST(facter_util_option_set, toggle_option) {
    option_set<options> s;
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s[options::foo]);

    s.toggle(options::foo);
    ASSERT_EQ(1u, s.count());
    ASSERT_TRUE(s[options::foo]);

    s.toggle(options::foo);
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s[options::foo]);
}

TEST(facter_util_option_set, count) {
    option_set<options> s;
    ASSERT_EQ(0u, s.count());

    s.toggle();
    ASSERT_EQ(s.size(), s.count());

    s.reset();
    s.set(options::foo);
    ASSERT_EQ(1u, s.count());

    s.set(options::bar);
    ASSERT_EQ(2u, s.count());

    s.set(options::baz);
    ASSERT_EQ(3u, s.count());
}

TEST(facter_util_option_set, size) {
    option_set<options> s;
    ASSERT_EQ(sizeof(int) * 8, s.size());
}

TEST(facter_util_option_set, test) {
    option_set<options> s;
    ASSERT_EQ(0u, s.count());
    ASSERT_FALSE(s.test(options::foo));
    ASSERT_FALSE(s.test(options::bar));
    ASSERT_FALSE(s.test(options::baz));

    s.set(options::bar);
    ASSERT_EQ(1u, s.count());
    ASSERT_FALSE(s.test(options::foo));
    ASSERT_TRUE(s.test(options::bar));
    ASSERT_FALSE(s.test(options::baz));
}

TEST(facter_util_option_set, empty) {
    option_set<options> s;
    ASSERT_TRUE(s.empty());

    s.set(options::bar);
    ASSERT_FALSE(s.empty());
}

TEST(facter_util_option_set, bitwise_and) {
    option_set<options> s1 = { options::foo, options::bar };
    ASSERT_EQ(2u, s1.count());
    ASSERT_TRUE(s1[options::foo]);
    ASSERT_TRUE(s1[options::bar]);
    ASSERT_FALSE(s1[options::baz]);

    option_set<options> s2 = { options::bar, options::baz };
    ASSERT_EQ(2u, s2.count());
    ASSERT_FALSE(s2[options::foo]);
    ASSERT_TRUE(s2[options::bar]);
    ASSERT_TRUE(s2[options::baz]);

    option_set<options> s3 = s1 & s2;
    ASSERT_EQ(1u, s3.count());
    ASSERT_FALSE(s3[options::foo]);
    ASSERT_TRUE(s3[options::bar]);
    ASSERT_FALSE(s3[options::baz]);
}

TEST(facter_util_option_set, bitwise_or) {
    option_set<options> s1 = { options::foo, options::bar };
    ASSERT_EQ(2u, s1.count());
    ASSERT_TRUE(s1[options::foo]);
    ASSERT_TRUE(s1[options::bar]);
    ASSERT_FALSE(s1[options::baz]);

    option_set<options> s2 = { options::baz };
    ASSERT_EQ(1u, s2.count());
    ASSERT_FALSE(s2[options::foo]);
    ASSERT_FALSE(s2[options::bar]);
    ASSERT_TRUE(s2[options::baz]);

    option_set<options> s3 = s1 | s2;
    ASSERT_EQ(3u, s3.count());
    ASSERT_TRUE(s3[options::foo]);
    ASSERT_TRUE(s3[options::bar]);
    ASSERT_TRUE(s3[options::baz]);
}

TEST(facter_util_option_set, bitwise_xor) {
    option_set<options> s1 = { options::foo, options::bar };
    ASSERT_EQ(2u, s1.count());
    ASSERT_TRUE(s1[options::foo]);
    ASSERT_TRUE(s1[options::bar]);
    ASSERT_FALSE(s1[options::baz]);

    option_set<options> s2 = { options::bar, options::baz };
    ASSERT_EQ(2u, s2.count());
    ASSERT_FALSE(s2[options::foo]);
    ASSERT_TRUE(s2[options::bar]);
    ASSERT_TRUE(s2[options::baz]);

    option_set<options> s3 = s1 ^ s2;
    ASSERT_EQ(2u, s3.count());
    ASSERT_TRUE(s3[options::foo]);
    ASSERT_FALSE(s3[options::bar]);
    ASSERT_TRUE(s3[options::baz]);
}
