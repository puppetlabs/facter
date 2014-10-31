#include <gmock/gmock.h>
#include <facter/facts/windows/networking_resolver.hpp>
#include <facter/util/windows/windows.hpp>
#include <Ws2tcpip.h>

using namespace std;
using namespace facter::facts;

// Test address manipulation utilities.

struct networking_utilities : windows::networking_resolver
{
 public:
    using networking_resolver::ignored_ipv4_address;
    using networking_resolver::ignored_ipv6_address;
    using networking_resolver::create_ipv4_mask;
    using networking_resolver::create_ipv6_mask;

    template <typename T>
    static std::string address_to_string(T const* addr, T const* mask = nullptr)
    {
        return networking_resolver::address_to_string(
            reinterpret_cast<sockaddr const*>(addr),
            reinterpret_cast<sockaddr const*>(mask));
    }
};


// IPv4 Tests

TEST(facter_facts_windows_networking_resolver, ignored_ipv4_address)
{
    // These don't check the validity of the address; that's handled by using system APIs to generate the addresses.
    constexpr char const* ignored_addresses[] = { "127.0.0.1", "169.254.7.14", "169.254.0.0", "169.254.255.255" };
    for (auto s : ignored_addresses) {
        ASSERT_TRUE(networking_utilities::ignored_ipv4_address(s)) << s << " not ignored";
    }

    constexpr char const* accepted_addresses[] = { "169.253.0.0", "169.255.0.0", "100.100.100.100", "0.0.0.0",
        "1.1.1.1", "10.0.18.142", "192.168.0.1", "255.255.255.255" };
    for (auto s : accepted_addresses) {
        ASSERT_FALSE(networking_utilities::ignored_ipv4_address(s)) << s << " falsely ignored";
    }
}

static constexpr sockaddr_in make_sockaddr_in(u_char a, u_char b, u_char c, u_char d)
{ return {AF_INET, 0u, in_addr{a, b, c, d}, {0, 0, 0, 0, 0, 0, 0, 0}}; }

bool operator== (in_addr const& a, in_addr const& b)
{ return a.S_un.S_addr == b.S_un.S_addr; }

bool operator!= (in_addr const& a, in_addr const& b) { return !(a == b); }

bool operator== (sockaddr_in const& a, sockaddr_in const& b)
{ return a.sin_family == b.sin_family && a.sin_addr == b.sin_addr; }

bool operator!= (sockaddr_in const& a, sockaddr_in const& b) { return !(a == b); }

struct ipv4_case { uint8_t masklen; sockaddr_in addr; string str; };
static const ipv4_case ip4_masks[] = {
    {0u,   make_sockaddr_in(0u, 0u, 0u, 0u),         "0.0.0.0"},
    {255u, make_sockaddr_in(255u, 255u, 255u, 255u), "255.255.255.255"},
    {32u,  make_sockaddr_in(255u, 255u, 255u, 255u), "255.255.255.255"},
    {33u,  make_sockaddr_in(255u, 255u, 255u, 255u), "255.255.255.255"},
    {24u,  make_sockaddr_in(255u, 255u, 255u, 0u),   "255.255.255.0"},
    {9u,   make_sockaddr_in(255u, 128u, 0u, 0u),     "255.128.0.0"},
    {1u,   make_sockaddr_in(128u, 0u, 0u, 0u),       "128.0.0.0"},
    {31u,  make_sockaddr_in(255u, 255u, 255u, 254u), "255.255.255.254"}
};

TEST(facter_facts_windows_networking_resolver, create_ipv4_mask)
{
    // Test various valid masklen, too large masklen, verify output.
    for (auto const& item : ip4_masks) {
        auto mask = networking_utilities::create_ipv4_mask(item.masklen);
        ASSERT_EQ(item.addr, mask) << "mask of length " << static_cast<int>(item.masklen) << " != " << item.str;
    }

    // Verify the boolean operator behaves as expected.
    ASSERT_NE(ip4_masks[0].addr, ip4_masks[1].addr);
    ASSERT_NE(ip4_masks[0].addr, ip4_masks[6].addr);
}

TEST(facter_facts_windows_networking_resolver, address_to_ipv4_string)
{
    const pair<sockaddr_in, string> ip4_cases[] = {
        {make_sockaddr_in(192u, 168u, 0u, 1u), "192.168.0.1"},
        {make_sockaddr_in(200u, 0u, 154u, 12u), "200.0.154.12"},
        {make_sockaddr_in(1u, 255u, 128u, 42u), "1.255.128.42"}
    };

    // Test various valid addresses to string.
    for (auto const& item : ip4_cases) {
        ASSERT_EQ(item.second, networking_utilities::address_to_string(&item.first));
    }

    // Test various mask addresses to string.
    for (auto const& item : ip4_masks) {
        ASSERT_EQ(item.str, networking_utilities::address_to_string(&item.addr));
    }
}

TEST(facter_facts_windows_networking_resolver, address_to_string_with_ipv4_mask)
{
    // Test address_to_string with masks applied.
    auto min = make_sockaddr_in(0u, 0u, 0u, 0u);
    auto max = make_sockaddr_in(255u, 255u, 255u, 255u);
    auto zoro = make_sockaddr_in(255u, 255u, 128u, 0u);
    auto v = make_sockaddr_in(128u, 0u, 0u, 0u);

    auto local = make_sockaddr_in(192u, 168u, 0u, 1u);
    auto outer = make_sockaddr_in(200u, 0u, 154u, 12u);

    ASSERT_EQ("0.0.0.0", networking_utilities::address_to_string(&local, &min));
    ASSERT_EQ("192.168.0.1", networking_utilities::address_to_string(&local, &max));
    ASSERT_EQ("192.168.0.0", networking_utilities::address_to_string(&local, &zoro));
    ASSERT_EQ("128.0.0.0", networking_utilities::address_to_string(&local, &v));
    ASSERT_EQ("0.0.0.0", networking_utilities::address_to_string(&outer, &min));
    ASSERT_EQ("200.0.154.12", networking_utilities::address_to_string(&outer, &max));
    ASSERT_EQ("200.0.128.0", networking_utilities::address_to_string(&outer, &zoro));
    ASSERT_EQ("128.0.0.0", networking_utilities::address_to_string(&outer, &v));
}


// IPv6 Tests

TEST(facter_facts_windows_networking_resolver, ignored_ipv6_address)
{
    constexpr char const* ignored_addresses[] = { "::1", "fe80::9c84:7ca1:794b:12ed", "fe80::75f2:2f55:823b:a513%10" };
    for (auto s : ignored_addresses) {
        ASSERT_TRUE(networking_utilities::ignored_ipv6_address(s)) << s << " not ignored";
    }

    constexpr char const* accepted_addresses[] = { "::fe80:75f2:2f55:823b:a513", "fe7f::75f2:2f55:823b:a513%10",
        "::2", "::fe01", "::fe80"};
    for (auto s : accepted_addresses) {
        ASSERT_FALSE(networking_utilities::ignored_ipv6_address(s)) << s << " falsely ignored";
    }
}

static sockaddr_in6 make_sockaddr_in6(array<u_char, 16> x)
{
    sockaddr_in6 addr = {AF_INET6};
    memcpy(addr.sin6_addr.u.Byte, x.data(), 16*sizeof(u_char));
    return addr;
}

bool operator== (in6_addr const& a, in6_addr const& b)
{ return 0 == memcmp(a.u.Word, b.u.Word, 8*sizeof(u_short)); }

bool operator!= (in6_addr const& a, in6_addr const& b) { return !(a == b); }

bool operator== (sockaddr_in6 const& a, sockaddr_in6 const& b)
{ return a.sin6_family == b.sin6_family && a.sin6_addr == b.sin6_addr; }

bool operator!= (sockaddr_in6 const& a, sockaddr_in6 const& b) { return !(a == b); }

struct ipv6_case { uint8_t masklen; string str; sockaddr_in6 addr; };
static const ipv6_case ip6_masks[] = {
    {0u,    "::",       make_sockaddr_in6({})},
    {1u,    "8000::",   make_sockaddr_in6({0x80u})},
    {4u,    "f000::",   make_sockaddr_in6({0xf0u})},
    {64u,   "ffff:ffff:ffff:ffff::",
        make_sockaddr_in6({0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu})},
    {65u,   "ffff:ffff:ffff:ffff:8000::",
        make_sockaddr_in6({0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0x80u})},
    {127u,  "ffff:ffff:ffff:ffff:ffff:ffff:ffff:fffe",
        make_sockaddr_in6({0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xfeu})},
    {128u,  "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
        make_sockaddr_in6({0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu})},
    {129u,  "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
        make_sockaddr_in6({0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu})}
};

TEST(facter_facts_windows_networking_resolver, create_ipv6_mask)
{
    // Test various valid masklen, too large masklen, verify output.
    for (auto const& item : ip6_masks) {
        auto mask = networking_utilities::create_ipv6_mask(item.masklen);
        ASSERT_EQ(item.addr, mask) <<
            "mask[" << static_cast<int>(item.masklen) << "] " << networking_utilities::address_to_string(&mask) <<
            " != [" << item.str << "] " << networking_utilities::address_to_string(&item.addr);
    }

    // Verify the boolean operator behaves as expected.
    ASSERT_NE(ip6_masks[0].addr, ip6_masks[1].addr);
    ASSERT_NE(ip6_masks[0].addr, ip6_masks[6].addr);
}

TEST(facter_facts_windows_networking_resolver, address_to_ipv6_string)
{
    const pair<sockaddr_in6, string> ip6_cases[] = {
        {make_sockaddr_in6({0u, 0u, 0u, 0u, 0xffu, 0xe9u, 0xffu, 0xffu, 0xffu, 0xabu, 1u}), "::ffe9:ffff:ffab:100:0:0"},
        {make_sockaddr_in6({0u, 0xffu, 0xe9u, 0xffu, 0xffu, 0xffu, 0xabu, 1u}), "ff:e9ff:ffff:ab01::"},
        {make_sockaddr_in6({0xfeu, 0x80u, 0x01u, 0x23u, 0u, 0u, 0u, 0u, 0x45u, 0x67u, 0x89u, 0xabu}), "fe80:123::4567:89ab:0:0"},
        {make_sockaddr_in6({0xfeu, 0x80u, 0x01u, 0x23u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0x45u, 0x67u, 0x89u, 0xabu}), "fe80:123::4567:89ab"},
        {make_sockaddr_in6({0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 0u, 1u}), "::1"},
    };

    // Test various valid addresses to string.
    for (auto const& item : ip6_cases) {
        ASSERT_EQ(item.second, networking_utilities::address_to_string(&item.first));
    }

    // Test various mask addresses to string.
    for (auto const& item : ip6_masks) {
        ASSERT_EQ(item.str, networking_utilities::address_to_string(&item.addr));
    }
}

TEST(facter_facts_windows_networking_resolver, address_to_string_with_ipv6_mask)
{
    // Test address_to_string with masks applied.
    auto min = make_sockaddr_in6({});
    auto max = make_sockaddr_in6({0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu,
        0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu});
    auto zoro = make_sockaddr_in6({0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu, 0xffu});
    auto v = make_sockaddr_in6({0xf8u});

    auto local = make_sockaddr_in6({0xfeu, 0x80u, 0x01u, 0x23u, 0u, 0u, 0u, 0u, 0x45u, 0x67u, 0x89u, 0xabu});
    auto outer = make_sockaddr_in6({0u, 0xffu, 0xe9u, 0xffu, 0xffu, 0xffu, 0xabu, 1u});

    ASSERT_EQ("::", networking_utilities::address_to_string(&local, &min));
    ASSERT_EQ("fe80:123::4567:89ab:0:0", networking_utilities::address_to_string(&local, &max));
    ASSERT_EQ("fe80:123::", networking_utilities::address_to_string(&local, &zoro));
    ASSERT_EQ("f800::", networking_utilities::address_to_string(&local, &v));
    ASSERT_EQ("::", networking_utilities::address_to_string(&outer, &min));
    ASSERT_EQ("ff:e9ff:ffff:ab01::", networking_utilities::address_to_string(&outer, &max));
    ASSERT_EQ("ff:e9ff:ffff:ab01::", networking_utilities::address_to_string(&outer, &zoro));
    ASSERT_EQ("::", networking_utilities::address_to_string(&outer, &v));
}
