#include <catch.hpp>
#include <internal/facts/resolvers/networking_resolver.hpp>
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

SCENARIO("using the networking resolver") {
    collection facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_networking_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0);
        }
    }
    WHEN("only hostname is present") {
        facts.add(make_shared<test_hostname_resolver>());
        REQUIRE(facts.size() == 3);
        THEN("a flat fact is added") {
            auto hostname = facts.get<string_value>(fact::hostname);
            REQUIRE(hostname);
            REQUIRE(hostname->value() == "hostname");
        }
        THEN("a structured fact is added") {
            auto networking = facts.get<map_value>(fact::networking);
            REQUIRE(networking);
            REQUIRE(networking->size() == 2);

            auto hostname = networking->get<string_value>("hostname");
            REQUIRE(hostname);
            REQUIRE(hostname->value() == "hostname");

            auto fqdn = networking->get<string_value>("fqdn");
            REQUIRE(fqdn);
            REQUIRE(fqdn->value() == "hostname");
        }
        THEN("the FQDN fact is the hostname") {
            auto fqdn = facts.get<string_value>(fact::fqdn);
            REQUIRE(fqdn);
            REQUIRE(fqdn->value() == "hostname");
        }
    }
    WHEN("only domain is present") {
        facts.add(make_shared<test_domain_resolver>());
        REQUIRE(facts.size() == 2);
        THEN("a flat fact is added") {
            auto domain = facts.get<string_value>(fact::domain);
            REQUIRE(domain);
            REQUIRE(domain->value() == "domain");
        }
        THEN("a structured fact is added") {
            auto networking = facts.get<map_value>(fact::networking);
            REQUIRE(networking);
            REQUIRE(networking->size() == 1);

            auto domain = networking->get<string_value>("domain");
            REQUIRE(domain);
            REQUIRE(domain->value() == "domain");
        }
        THEN("the FQDN fact is not present") {
            auto fqdn = facts.get<string_value>(fact::fqdn);
            REQUIRE_FALSE(fqdn);
        }
    }
    WHEN("FQDN is present") {
        facts.add(make_shared<test_fqdn_resolver>());
        REQUIRE(facts.size() == 2);
        THEN("a flat fact is added") {
            auto fqdn = facts.get<string_value>(fact::fqdn);
            REQUIRE(fqdn);
            REQUIRE(fqdn->value() == "fqdn");
        }
        THEN("a structured fact is added") {
            auto networking = facts.get<map_value>(fact::networking);
            REQUIRE(networking);
            REQUIRE(networking->size() == 1);
            auto fqdn = networking->get<string_value>("fqdn");
            REQUIRE(fqdn);
            REQUIRE(fqdn->value() == "fqdn");
        }
        THEN("the FQDN fact is present") {
            auto fqdn = facts.get<string_value>(fact::fqdn);
            REQUIRE(fqdn);
            REQUIRE(fqdn->value() == "fqdn");
        }
    }
    WHEN("FQDN is not present") {
        facts.add(make_shared<test_missing_fqdn_resolver>());
        REQUIRE(facts.size() == 4);
        THEN("the FQDN fact is the combination of hostname and domain") {
            auto svalue = facts.get<string_value>(fact::hostname);
            REQUIRE(svalue);
            REQUIRE(svalue->value() == "hostname");
            svalue = facts.get<string_value>(fact::domain);
            REQUIRE(svalue);
            REQUIRE(svalue->value() == "domain.com");
            svalue = facts.get<string_value>(fact::fqdn);
            REQUIRE(svalue);
            REQUIRE(svalue->value() == "hostname.domain.com");
        }
        THEN("the FQDN in the structured fact is the combination of hostname and domain") {
            auto networking = facts.get<map_value>(fact::networking);
            REQUIRE(networking);
            REQUIRE(networking->size() == 3);
            auto svalue = networking->get<string_value>("hostname");
            REQUIRE(svalue);
            REQUIRE(svalue->value() == "hostname");
            svalue = networking->get<string_value>("domain");
            REQUIRE(svalue);
            REQUIRE(svalue->value() == "domain.com");
            svalue = networking->get<string_value>("fqdn");
            REQUIRE(svalue);
            REQUIRE(svalue->value() == "hostname.domain.com");
        }
    }
    WHEN("network interfaces are present") {
        facts.add(make_shared<test_interface_resolver>());
        REQUIRE(facts.size() == 50);
        THEN("the DHCP servers fact is present") {
            auto dhcp_servers = facts.get<map_value>(fact::dhcp_servers);
            REQUIRE(dhcp_servers);
            REQUIRE(dhcp_servers->size() == 6);
            for (unsigned int i = 0; i < 5; ++i) {
                string num = to_string(i);
                auto server = dhcp_servers->get<string_value>("iface" + num);
                REQUIRE(server);
                REQUIRE(server->value() == "dhcp" + num);
            }
            auto dhcp = dhcp_servers->get<string_value>("system");
            REQUIRE(dhcp);
            REQUIRE(dhcp->value() == "dhcp2");
        }
        THEN("the interface names fact is present") {
            auto interfaces_list = facts.get<string_value>(fact::interfaces);
            REQUIRE(interfaces_list);
            REQUIRE(interfaces_list->value() == "iface0,iface1,iface2,iface3,iface4");
        }
        THEN("the interface flat facts are present") {
            for (unsigned int i = 0; i < 5; ++i) {
                string num = to_string(i);
                auto ip = facts.get<string_value>(fact::ipaddress + string("_iface") + num);
                REQUIRE(ip);
                REQUIRE(ip->value() == "ip" + num);
                auto ip6 = facts.get<string_value>(fact::ipaddress6 + string("_iface") + num);
                REQUIRE(ip6);
                REQUIRE(ip6->value() == "ip6" + num);
                auto macaddress = facts.get<string_value>(fact::macaddress + string("_iface") + num);
                REQUIRE(macaddress);
                REQUIRE(macaddress->value() == "macaddress" + num);
                auto mtu = facts.get<integer_value>(fact::mtu + string("_iface") + num);
                REQUIRE(mtu);
                REQUIRE(mtu->value() == i);
                auto netmask = facts.get<string_value>(fact::netmask + string("_iface") + num);
                REQUIRE(netmask);
                REQUIRE(netmask->value() == "netmask" + num);
                auto netmask6 = facts.get<string_value>(fact::netmask6 + string("_iface") + num);
                REQUIRE(netmask6);
                REQUIRE(netmask6->value() == "netmask6" + num);
                auto network = facts.get<string_value>(fact::network + string("_iface") + num);
                REQUIRE(network);
                REQUIRE(network->value() == "network" + num);
                auto network6 = facts.get<string_value>(fact::network6 + string("_iface") + num);
                REQUIRE(network6);
                REQUIRE(network6->value() == "network6" + num);
            }
        }
        THEN("the system fact facts are present") {
            auto ip = facts.get<string_value>(fact::ipaddress);
            REQUIRE(ip);
            REQUIRE(ip->value() == "ip2");
            auto ip6 = facts.get<string_value>(fact::ipaddress6);
            REQUIRE(ip6);
            REQUIRE(ip6->value() == "ip62");
            auto macaddress = facts.get<string_value>(fact::macaddress);
            REQUIRE(macaddress);
            REQUIRE(macaddress->value() == "macaddress2");
            auto netmask = facts.get<string_value>(fact::netmask);
            REQUIRE(netmask);
            REQUIRE(netmask->value() == "netmask2");
            auto netmask6 = facts.get<string_value>(fact::netmask6);
            REQUIRE(netmask6);
            REQUIRE(netmask6->value() == "netmask62");
            auto network = facts.get<string_value>(fact::network);
            REQUIRE(network);
            REQUIRE(network->value() == "network2");
            auto network6 = facts.get<string_value>(fact::network6);
            REQUIRE(network6);
            REQUIRE(network6->value() == "network62");
        }
        THEN("the networking structured fact is present") {
            auto networking = facts.get<map_value>(fact::networking);
            REQUIRE(networking);
            REQUIRE(networking->size() == 10);
            auto dhcp = networking->get<string_value>("dhcp");
            REQUIRE(dhcp);
            REQUIRE(dhcp->value() == "dhcp2");
            auto ip = networking->get<string_value>("ip");
            REQUIRE(ip);
            REQUIRE(ip->value() == "ip2");
            auto ip6 = networking->get<string_value>("ip6");
            REQUIRE(ip6);
            REQUIRE(ip6->value() == "ip62");
            auto macaddress = networking->get<string_value>("mac");
            REQUIRE(macaddress);
            REQUIRE(macaddress->value() == "macaddress2");
            auto netmask = networking->get<string_value>("netmask");
            REQUIRE(netmask);
            REQUIRE(netmask->value() == "netmask2");
            auto netmask6 = networking->get<string_value>("netmask6");
            REQUIRE(netmask6);
            REQUIRE(netmask6->value() == "netmask62");
            auto network = networking->get<string_value>("network");
            REQUIRE(network);
            REQUIRE(network->value() == "network2");
            auto network6 = networking->get<string_value>("network6");
            REQUIRE(network6);
            REQUIRE(network6->value() == "network62");
            auto mtu = networking->get<integer_value>("mtu");
            REQUIRE(mtu);
            REQUIRE(mtu->value() == 2);
            auto interfaces = networking->get<map_value>("interfaces");
            REQUIRE(interfaces);
            for (unsigned int i = 0; i < 5; ++i) {
                string num = to_string(i);
                auto interface = interfaces->get<map_value>("iface" + num);
                REQUIRE(interface);
                dhcp = interface->get<string_value>("dhcp");
                REQUIRE(dhcp);
                REQUIRE(dhcp->value() == "dhcp" + num);
                ip = interface->get<string_value>("ip");
                REQUIRE(ip);
                REQUIRE(ip->value() == "ip" + num);
                ip6 = interface->get<string_value>("ip6");
                REQUIRE(ip6);
                REQUIRE(ip6->value() == "ip6" + num);
                macaddress = interface->get<string_value>("mac");
                REQUIRE(macaddress);
                REQUIRE(macaddress->value() == "macaddress" + num);
                netmask = interface->get<string_value>("netmask");
                REQUIRE(netmask);
                REQUIRE(netmask->value() == "netmask" + num);
                netmask6 = interface->get<string_value>("netmask6");
                REQUIRE(netmask6);
                REQUIRE(netmask6->value() == "netmask6" + num);
                network = interface->get<string_value>("network");
                REQUIRE(network);
                REQUIRE(network->value() == "network" + num);
                network6 = interface->get<string_value>("network6");
                REQUIRE(network6);
                REQUIRE(network6->value() == "network6" + num);
                mtu = interface->get<integer_value>("mtu");
                REQUIRE(mtu);
                REQUIRE(mtu->value() == i);
            }
        }
    }
}
