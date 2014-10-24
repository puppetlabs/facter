#include <gmock/gmock.h>
#include <facter/facts/resolvers/networking_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_networking_resolver : networking_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_hostname_resolver : networking_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.hostname = "hostname";
        return result;
    }
};

struct test_domain_resolver : networking_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.domain = "domain";
        return result;
    }
};

struct test_fqdn_resolver : networking_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.fqdn = "fqdn";
        return result;
    }
};

struct test_missing_fqdn_resolver : networking_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.hostname = "hostname";
        result.domain = "domain.com";
        return result;
    }
};

struct test_interface_resolver : networking_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        for (int i = 0; i < 5; ++i) {
            string num = to_string(i);

            interface iface;
            iface.name = "iface" + num;
            iface.dhcp_server = "dhcp" + num;
            iface.address.v4 = "ip" + num;
            iface.address.v6 = "ip6" + num;
            iface.netmask.v4 = "netmask" + num;
            iface.netmask.v6 = "netmask6" + num;
            iface.network.v4 = "network" + num;
            iface.network.v6 = "network6" + num;
            iface.macaddress = "macaddress" + num;
            iface.mtu = i;
            result.interfaces.emplace_back(move(iface));
        }
        result.primary_interface = "iface2";
        return result;
    }
};

TEST(facter_facts_resolvers_networking_resolver, empty)
{
    collection facts;
    facts.add(make_shared<empty_networking_resolver>());
    ASSERT_EQ(0u, facts.size());
}

TEST(facter_facts_resolvers_networking_resolver, hostname)
{
    collection facts;
    facts.add(make_shared<test_hostname_resolver>());
    ASSERT_EQ(3u, facts.size());

    auto hostname = facts.get<string_value>(fact::hostname);
    ASSERT_NE(nullptr, hostname);
    ASSERT_EQ("hostname", hostname->value());

    auto fqdn = facts.get<string_value>(fact::fqdn);
    ASSERT_NE(nullptr, fqdn);
    ASSERT_EQ("hostname", fqdn->value());

    auto networking = facts.get<map_value>(fact::networking);
    ASSERT_NE(nullptr, networking);
    ASSERT_EQ(2u, networking->size());

    hostname = networking->get<string_value>("hostname");
    ASSERT_NE(nullptr, hostname);
    ASSERT_EQ("hostname", hostname->value());

    fqdn = networking->get<string_value>("fqdn");
    ASSERT_NE(nullptr, fqdn);
    ASSERT_EQ("hostname", fqdn->value());
}

TEST(facter_facts_resolvers_networking_resolver, domain)
{
    collection facts;
    facts.add(make_shared<test_domain_resolver>());
    ASSERT_EQ(2u, facts.size());

    auto domain = facts.get<string_value>(fact::domain);
    ASSERT_NE(nullptr, domain);
    ASSERT_EQ("domain", domain->value());

    auto networking = facts.get<map_value>(fact::networking);
    ASSERT_NE(nullptr, networking);
    ASSERT_EQ(1u, networking->size());

    domain = networking->get<string_value>("domain");
    ASSERT_NE(nullptr, domain);
    ASSERT_EQ("domain", domain->value());
}

TEST(facter_facts_resolvers_networking_resolver, fqdn)
{
    collection facts;
    facts.add(make_shared<test_fqdn_resolver>());
    ASSERT_EQ(2u, facts.size());

    auto fqdn = facts.get<string_value>(fact::fqdn);
    ASSERT_NE(nullptr, fqdn);
    ASSERT_EQ("fqdn", fqdn->value());

    auto networking = facts.get<map_value>(fact::networking);
    ASSERT_NE(nullptr, networking);
    ASSERT_EQ(1u, networking->size());

    fqdn = networking->get<string_value>("fqdn");
    ASSERT_NE(nullptr, fqdn);
    ASSERT_EQ("fqdn", fqdn->value());
}

TEST(facter_facts_resolvers_networking_resolver, missing_fqdn)
{
    collection facts;
    facts.add(make_shared<test_missing_fqdn_resolver>());
    ASSERT_EQ(4u, facts.size());

    auto svalue = facts.get<string_value>(fact::hostname);
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("hostname", svalue->value());

    svalue = facts.get<string_value>(fact::domain);
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("domain.com", svalue->value());

    svalue = facts.get<string_value>(fact::fqdn);
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("hostname.domain.com", svalue->value());

    auto networking = facts.get<map_value>(fact::networking);
    ASSERT_NE(nullptr, networking);
    ASSERT_EQ(3u, networking->size());

    svalue = networking->get<string_value>("hostname");
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("hostname", svalue->value());

    svalue = networking->get<string_value>("domain");
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("domain.com", svalue->value());

    svalue = networking->get<string_value>("fqdn");
    ASSERT_NE(nullptr, svalue);
    ASSERT_EQ("hostname.domain.com", svalue->value());
}

TEST(facter_facts_resolvers_networking_resolver, interfaces)
{
    collection facts;
    facts.add(make_shared<test_interface_resolver>());
    ASSERT_EQ(50u, facts.size());

    auto dhcp_servers = facts.get<map_value>(fact::dhcp_servers);
    ASSERT_NE(nullptr, dhcp_servers);
    ASSERT_EQ(6u, dhcp_servers->size());

    for (unsigned int i = 0; i < 5; ++i) {
        string num = to_string(i);

        auto server = dhcp_servers->get<string_value>("iface" + num);
        ASSERT_NE(nullptr, server);
        ASSERT_EQ("dhcp" + num, server->value());
    }

    auto dhcp = dhcp_servers->get<string_value>("system");
    ASSERT_NE(nullptr, dhcp);
    ASSERT_EQ("dhcp2", dhcp->value());

    auto interfaces_list = facts.get<string_value>(fact::interfaces);
    ASSERT_NE(nullptr, interfaces_list);
    ASSERT_EQ("iface0,iface1,iface2,iface3,iface4", interfaces_list->value());

    for (unsigned int i = 0; i < 5; ++i) {
        string num = to_string(i);

        auto ip = facts.get<string_value>(fact::ipaddress + string("_iface") + num);
        ASSERT_NE(nullptr, ip);
        ASSERT_EQ("ip" + num, ip->value());

        auto ip6 = facts.get<string_value>(fact::ipaddress6 + string("_iface") + num);
        ASSERT_NE(nullptr, ip6);
        ASSERT_EQ("ip6" + num, ip6->value());

        auto macaddress = facts.get<string_value>(fact::macaddress + string("_iface") + num);
        ASSERT_NE(nullptr, macaddress);
        ASSERT_EQ("macaddress" + num, macaddress->value());

        auto mtu = facts.get<integer_value>(fact::mtu + string("_iface") + num);
        ASSERT_NE(nullptr, mtu);
        ASSERT_EQ(i, mtu->value());

        auto netmask = facts.get<string_value>(fact::netmask + string("_iface") + num);
        ASSERT_NE(nullptr, netmask);
        ASSERT_EQ("netmask" + num, netmask->value());

        auto netmask6 = facts.get<string_value>(fact::netmask6 + string("_iface") + num);
        ASSERT_NE(nullptr, netmask6);
        ASSERT_EQ("netmask6" + num, netmask6->value());

        auto network = facts.get<string_value>(fact::network + string("_iface") + num);
        ASSERT_NE(nullptr, network);
        ASSERT_EQ("network" + num, network->value());

        auto network6 = facts.get<string_value>(fact::network6 + string("_iface") + num);
        ASSERT_NE(nullptr, network6);
        ASSERT_EQ("network6" + num, network6->value());
    }

    auto ip = facts.get<string_value>(fact::ipaddress);
    ASSERT_NE(nullptr, ip);
    ASSERT_EQ("ip2", ip->value());

    auto ip6 = facts.get<string_value>(fact::ipaddress6);
    ASSERT_NE(nullptr, ip6);
    ASSERT_EQ("ip62", ip6->value());

    auto macaddress = facts.get<string_value>(fact::macaddress);
    ASSERT_NE(nullptr, macaddress);
    ASSERT_EQ("macaddress2", macaddress->value());

    auto netmask = facts.get<string_value>(fact::netmask);
    ASSERT_NE(nullptr, netmask);
    ASSERT_EQ("netmask2", netmask->value());

    auto netmask6 = facts.get<string_value>(fact::netmask6);
    ASSERT_NE(nullptr, netmask6);
    ASSERT_EQ("netmask62", netmask6->value());

    auto network = facts.get<string_value>(fact::network);
    ASSERT_NE(nullptr, network);
    ASSERT_EQ("network2", network->value());

    auto network6 = facts.get<string_value>(fact::network6);
    ASSERT_NE(nullptr, network6);
    ASSERT_EQ("network62", network6->value());

    auto networking = facts.get<map_value>(fact::networking);
    ASSERT_NE(nullptr, networking);
    ASSERT_EQ(10u, networking->size());

    dhcp = networking->get<string_value>("dhcp");
    ASSERT_NE(nullptr, dhcp);
    ASSERT_EQ("dhcp2", dhcp->value());

    ip = networking->get<string_value>("ip");
    ASSERT_NE(nullptr, ip);
    ASSERT_EQ("ip2", ip->value());

    ip6 = networking->get<string_value>("ip6");
    ASSERT_NE(nullptr, ip6);
    ASSERT_EQ("ip62", ip6->value());

    macaddress = networking->get<string_value>("mac");
    ASSERT_NE(nullptr, macaddress);
    ASSERT_EQ("macaddress2", macaddress->value());

    netmask = networking->get<string_value>("netmask");
    ASSERT_NE(nullptr, netmask);
    ASSERT_EQ("netmask2", netmask->value());

    netmask6 = networking->get<string_value>("netmask6");
    ASSERT_NE(nullptr, netmask6);
    ASSERT_EQ("netmask62", netmask6->value());

    network = networking->get<string_value>("network");
    ASSERT_NE(nullptr, network);
    ASSERT_EQ("network2", network->value());

    network6 = networking->get<string_value>("network6");
    ASSERT_NE(nullptr, network6);
    ASSERT_EQ("network62", network6->value());

    auto mtu = networking->get<integer_value>("mtu");
    ASSERT_NE(nullptr, mtu);
    ASSERT_EQ(2, mtu->value());

    auto interfaces = networking->get<map_value>("interfaces");
    ASSERT_NE(nullptr, interfaces);

    for (unsigned int i = 0; i < 5; ++i) {
        string num = to_string(i);

        auto interface = interfaces->get<map_value>("iface" + num);
        ASSERT_NE(nullptr, interface);

        dhcp = interface->get<string_value>("dhcp");
        ASSERT_NE(nullptr, dhcp);
        ASSERT_EQ("dhcp" + num, dhcp->value());

        ip = interface->get<string_value>("ip");
        ASSERT_NE(nullptr, ip);
        ASSERT_EQ("ip" + num, ip->value());

        ip6 = interface->get<string_value>("ip6");
        ASSERT_NE(nullptr, ip6);
        ASSERT_EQ("ip6" + num, ip6->value());

        macaddress = interface->get<string_value>("mac");
        ASSERT_NE(nullptr, macaddress);
        ASSERT_EQ("macaddress" + num, macaddress->value());

        netmask = interface->get<string_value>("netmask");
        ASSERT_NE(nullptr, netmask);
        ASSERT_EQ("netmask" + num, netmask->value());

        netmask6 = interface->get<string_value>("netmask6");
        ASSERT_NE(nullptr, netmask6);
        ASSERT_EQ("netmask6" + num, netmask6->value());

        network = interface->get<string_value>("network");
        ASSERT_NE(nullptr, network);
        ASSERT_EQ("network" + num, network->value());

        network6 = interface->get<string_value>("network6");
        ASSERT_NE(nullptr, network6);
        ASSERT_EQ("network6" + num, network6->value());

        mtu = interface->get<integer_value>("mtu");
        ASSERT_NE(nullptr, mtu);
        ASSERT_EQ(i, mtu->value());
    }
}
