#include <catch.hpp>
#include <internal/facts/resolvers/networking_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include "../../collection_fixture.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;
using namespace facter::testing;

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
            iface.name = "iface_" + num;
            iface.dhcp_server = "dhcp_" + num;
            for (int binding_index = 0; binding_index < 2; ++binding_index) {
                string binding_num = to_string(binding_index);
                iface.ipv4_bindings.emplace_back(binding { "ip_" + num + "_" + binding_num, "netmask_" + num + "_" + binding_num, "network_" + num + "_" + binding_num });
                iface.ipv6_bindings.emplace_back(binding { "ip6_" + num + "_" + binding_num, "netmask6_" + num + "_" + binding_num, "network6_" + num + "_" + binding_num });
            }
            iface.macaddress = "macaddress_" + num;
            iface.mtu = i;
            result.interfaces.emplace_back(move(iface));
        }
        result.primary_interface = "iface_2";
        return result;
    }
};

SCENARIO("using the networking resolver") {
    collection_fixture facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_networking_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0u);
        }
    }
    WHEN("only hostname is present") {
        facts.add(make_shared<test_hostname_resolver>());
        REQUIRE(facts.size() == 3u);
        THEN("a flat fact is added") {
            auto hostname = facts.get<string_value>(fact::hostname);
            REQUIRE(hostname);
            REQUIRE(hostname->value() == "hostname");
        }
        THEN("a structured fact is added") {
            auto networking = facts.get<map_value>(fact::networking);
            REQUIRE(networking);
            REQUIRE(networking->size() == 2u);

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
        REQUIRE(facts.size() == 2u);
        THEN("a flat fact is added") {
            auto domain = facts.get<string_value>(fact::domain);
            REQUIRE(domain);
            REQUIRE(domain->value() == "domain");
        }
        THEN("a structured fact is added") {
            auto networking = facts.get<map_value>(fact::networking);
            REQUIRE(networking);
            REQUIRE(networking->size() == 1u);

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
        REQUIRE(facts.size() == 2u);
        THEN("a flat fact is added") {
            auto fqdn = facts.get<string_value>(fact::fqdn);
            REQUIRE(fqdn);
            REQUIRE(fqdn->value() == "fqdn");
        }
        THEN("a structured fact is added") {
            auto networking = facts.get<map_value>(fact::networking);
            REQUIRE(networking);
            REQUIRE(networking->size() == 1u);
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
        REQUIRE(facts.size() == 4u);
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
            REQUIRE(networking->size() == 3u);
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
        REQUIRE(facts.size() == 50u);
        THEN("the DHCP servers fact is present") {
            auto dhcp_servers = facts.get<map_value>(fact::dhcp_servers);
            REQUIRE(dhcp_servers);
            REQUIRE(dhcp_servers->size() == 6u);
            for (unsigned int i = 0; i < 5; ++i) {
                string num = to_string(i);
                auto server = dhcp_servers->get<string_value>("iface_" + num);
                REQUIRE(server);
                REQUIRE(server->value() == "dhcp_" + num);
            }
            auto dhcp = dhcp_servers->get<string_value>("system");
            REQUIRE(dhcp);
            REQUIRE(dhcp->value() == "dhcp_2");
        }
        THEN("the interface names fact is present") {
            auto interfaces_list = facts.get<string_value>(fact::interfaces);
            REQUIRE(interfaces_list);
            REQUIRE(interfaces_list->value() == "iface_0,iface_1,iface_2,iface_3,iface_4");
        }
        THEN("the interface flat facts are present") {
            for (unsigned int i = 0; i < 5; ++i) {
                string num = to_string(i);
                auto ip = facts.get<string_value>(fact::ipaddress + string("_iface_") + num);
                REQUIRE(ip);
                REQUIRE(ip->value() == "ip_" + num + "_0");
                auto ip6 = facts.get<string_value>(fact::ipaddress6 + string("_iface_") + num);
                REQUIRE(ip6);
                REQUIRE(ip6->value() == "ip6_" + num + "_0");
                auto macaddress = facts.get<string_value>(fact::macaddress + string("_iface_") + num);
                REQUIRE(macaddress);
                REQUIRE(macaddress->value() == "macaddress_" + num);
                auto mtu = facts.get<integer_value>(fact::mtu + string("_iface_") + num);
                REQUIRE(mtu);
                REQUIRE(mtu->value() == i);
                auto netmask = facts.get<string_value>(fact::netmask + string("_iface_") + num);
                REQUIRE(netmask);
                REQUIRE(netmask->value() == "netmask_" + num + "_0");
                auto netmask6 = facts.get<string_value>(fact::netmask6 + string("_iface_") + num);
                REQUIRE(netmask6);
                REQUIRE(netmask6->value() == "netmask6_" + num + "_0");
                auto network = facts.get<string_value>(fact::network + string("_iface_") + num);
                REQUIRE(network);
                REQUIRE(network->value() == "network_" + num + "_0");
                auto network6 = facts.get<string_value>(fact::network6 + string("_iface_") + num);
                REQUIRE(network6);
                REQUIRE(network6->value() == "network6_" + num + "_0");
            }
        }
        THEN("the system fact facts are present") {
            auto ip = facts.get<string_value>(fact::ipaddress);
            REQUIRE(ip);
            REQUIRE(ip->value() == "ip_2_0");
            auto ip6 = facts.get<string_value>(fact::ipaddress6);
            REQUIRE(ip6);
            REQUIRE(ip6->value() == "ip6_2_0");
            auto macaddress = facts.get<string_value>(fact::macaddress);
            REQUIRE(macaddress);
            REQUIRE(macaddress->value() == "macaddress_2");
            auto netmask = facts.get<string_value>(fact::netmask);
            REQUIRE(netmask);
            REQUIRE(netmask->value() == "netmask_2_0");
            auto netmask6 = facts.get<string_value>(fact::netmask6);
            REQUIRE(netmask6);
            REQUIRE(netmask6->value() == "netmask6_2_0");
            auto network = facts.get<string_value>(fact::network);
            REQUIRE(network);
            REQUIRE(network->value() == "network_2_0");
            auto network6 = facts.get<string_value>(fact::network6);
            REQUIRE(network6);
            REQUIRE(network6->value() == "network6_2_0");
        }
        THEN("the networking structured fact is present") {
            auto networking = facts.get<map_value>(fact::networking);
            REQUIRE(networking);
            REQUIRE(networking->size() == 11u);
            auto primary = networking->get<string_value>("primary");
            REQUIRE(primary);
            REQUIRE(primary->value() == "iface_2");
            auto dhcp = networking->get<string_value>("dhcp");
            REQUIRE(dhcp);
            REQUIRE(dhcp->value() == "dhcp_2");
            auto ip = networking->get<string_value>("ip");
            REQUIRE(ip);
            REQUIRE(ip->value() == "ip_2_0");
            auto ip6 = networking->get<string_value>("ip6");
            REQUIRE(ip6);
            REQUIRE(ip6->value() == "ip6_2_0");
            auto macaddress = networking->get<string_value>("mac");
            REQUIRE(macaddress);
            REQUIRE(macaddress->value() == "macaddress_2");
            auto netmask = networking->get<string_value>("netmask");
            REQUIRE(netmask);
            REQUIRE(netmask->value() == "netmask_2_0");
            auto netmask6 = networking->get<string_value>("netmask6");
            REQUIRE(netmask6);
            REQUIRE(netmask6->value() == "netmask6_2_0");
            auto network = networking->get<string_value>("network");
            REQUIRE(network);
            REQUIRE(network->value() == "network_2_0");
            auto network6 = networking->get<string_value>("network6");
            REQUIRE(network6);
            REQUIRE(network6->value() == "network6_2_0");
            auto mtu = networking->get<integer_value>("mtu");
            REQUIRE(mtu);
            REQUIRE(mtu->value() == 2);
            auto interfaces = networking->get<map_value>("interfaces");
            REQUIRE(interfaces);
            for (unsigned int i = 0; i < 5; ++i) {
                string num = to_string(i);
                auto interface = interfaces->get<map_value>("iface_" + num);
                REQUIRE(interface);
                dhcp = interface->get<string_value>("dhcp");
                REQUIRE(dhcp);
                REQUIRE(dhcp->value() == "dhcp_" + num);
                ip = interface->get<string_value>("ip");
                REQUIRE(ip);
                REQUIRE(ip->value() == "ip_" + num + "_0");
                ip6 = interface->get<string_value>("ip6");
                REQUIRE(ip6);
                REQUIRE(ip6->value() == "ip6_" + num + "_0");
                macaddress = interface->get<string_value>("mac");
                REQUIRE(macaddress);
                REQUIRE(macaddress->value() == "macaddress_" + num);
                netmask = interface->get<string_value>("netmask");
                REQUIRE(netmask);
                REQUIRE(netmask->value() == "netmask_" + num + "_0");
                netmask6 = interface->get<string_value>("netmask6");
                REQUIRE(netmask6);
                REQUIRE(netmask6->value() == "netmask6_" + num + "_0");
                network = interface->get<string_value>("network");
                REQUIRE(network);
                REQUIRE(network->value() == "network_" + num + "_0");
                network6 = interface->get<string_value>("network6");
                REQUIRE(network6);
                REQUIRE(network6->value() == "network6_" + num + "_0");
                mtu = interface->get<integer_value>("mtu");
                REQUIRE(mtu);
                REQUIRE(mtu->value() == i);
                auto bindings = interface->get<array_value>("bindings");
                REQUIRE(bindings);
                REQUIRE(bindings->size() == 2);
                for (size_t binding_index = 0; binding_index < bindings->size(); ++binding_index) {
                    auto interface_num = to_string(binding_index);
                    auto binding = bindings->get<map_value>(binding_index);
                    REQUIRE(binding);
                    auto address = binding->get<string_value>("address");
                    REQUIRE(address);
                    REQUIRE(address->value() == "ip_" + num + "_" + interface_num);
                    auto netmask = binding->get<string_value>("netmask");
                    REQUIRE(netmask);
                    REQUIRE(netmask->value() == "netmask_" + num + "_" + interface_num);
                    auto network = binding->get<string_value>("network");
                    REQUIRE(network);
                    REQUIRE(network->value() == "network_" + num + "_" + interface_num);
                }
                bindings = interface->get<array_value>("bindings6");
                REQUIRE(bindings);
                REQUIRE(bindings->size() == 2);
                for (size_t binding_index = 0; binding_index < bindings->size(); ++binding_index) {
                    auto interface_num = to_string(binding_index);
                    auto binding = bindings->get<map_value>(binding_index);
                    REQUIRE(binding);
                    auto address = binding->get<string_value>("address");
                    REQUIRE(address);
                    REQUIRE(address->value() == "ip6_" + num + "_" + interface_num);
                    auto netmask = binding->get<string_value>("netmask");
                    REQUIRE(netmask);
                    REQUIRE(netmask->value() == "netmask6_" + num + "_" + interface_num);
                    auto network = binding->get<string_value>("network");
                    REQUIRE(network);
                    REQUIRE(network->value() == "network6_" + num + "_" + interface_num);
                }
            }
        }
    }
}

SCENARIO("ignored IPv4 addresses") {
    char const* ignored_addresses[] = {
            "",
            "127.0.0.1",
            "169.254.7.14",
            "169.254.0.0",
            "169.254.255.255"
    };
    for (auto s : ignored_addresses) {
        CAPTURE(s);
        REQUIRE(networking_resolver::ignored_ipv4_address(s));
    }
    char const* accepted_addresses[] = {
            "169.253.0.0",
            "169.255.0.0",
            "100.100.100.100",
            "0.0.0.0",
            "1.1.1.1",
            "10.0.18.142",
            "192.168.0.1",
            "255.255.255.255"
    };
    for (auto s : accepted_addresses) {
        CAPTURE(s);
        REQUIRE_FALSE(networking_resolver::ignored_ipv4_address(s));
    }
}


SCENARIO("ignore IPv6 adddresses") {
    char const* ignored_addresses[] = {
            "",
            "::1",
            "fe80::9c84:7ca1:794b:12ed",
            "fe80::75f2:2f55:823b:a513%10"
    };
    for (auto s : ignored_addresses) {
        CAPTURE(s);
        REQUIRE(networking_resolver::ignored_ipv6_address(s));
    }
    char const* accepted_addresses[] = {
            "::fe80:75f2:2f55:823b:a513",
            "fe7f::75f2:2f55:823b:a513%10",
            "::2",
            "::fe01",
            "::fe80"
    };
    for (auto s : accepted_addresses) {
        CAPTURE(s);
        REQUIRE_FALSE(networking_resolver::ignored_ipv6_address(s));
    }
}
