#include <catch.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <internal/util/regex.hpp>
#include <yaml-cpp/yaml.h>
#include <boost/nowide/fstream.hpp>
#include "../fixtures.hpp"

// Include all base resolvers here
#include <internal/facts/resolvers/augeas_resolver.hpp>
#include <internal/facts/resolvers/disk_resolver.hpp>
#include <internal/facts/resolvers/dmi_resolver.hpp>
#include <internal/facts/resolvers/ec2_resolver.hpp>
#include <internal/facts/resolvers/filesystem_resolver.hpp>
#include <internal/facts/resolvers/gce_resolver.hpp>
#include <internal/facts/resolvers/identity_resolver.hpp>
#include <internal/facts/resolvers/kernel_resolver.hpp>
#include <internal/facts/resolvers/load_average_resolver.hpp>
#include <internal/facts/resolvers/memory_resolver.hpp>
#include <internal/facts/resolvers/networking_resolver.hpp>
#include <internal/facts/resolvers/operating_system_resolver.hpp>
#include <internal/facts/resolvers/path_resolver.hpp>
#include <internal/facts/resolvers/processor_resolver.hpp>
#include <internal/facts/resolvers/ruby_resolver.hpp>
#include <internal/facts/resolvers/ssh_resolver.hpp>
#include <internal/facts/resolvers/system_profiler_resolver.hpp>
#include <internal/facts/resolvers/timezone_resolver.hpp>
#include <internal/facts/resolvers/uptime_resolver.hpp>
#include <internal/facts/resolvers/virtualization_resolver.hpp>
#include <internal/facts/resolvers/xen_resolver.hpp>
#include <internal/facts/resolvers/zfs_resolver.hpp>
#include <internal/facts/resolvers/zone_resolver.hpp>
#include <internal/facts/resolvers/zpool_resolver.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::testing;

// For every base resolver, implement a resolver that outputs the minimum values to pass schema validation
// We don't care about the actual data in the facts, only that it conforms to the schema

struct augeas_resolver : resolvers::augeas_resolver
{
 protected:
    virtual string get_version() override
    {
        return "1.1.0";
    }
};

struct disk_resolver : resolvers::disk_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.disks.push_back({
            "name",
            "vendor",
            "model",
            "product",
            1234
        });
        return result;
    }
};

struct dmi_resolver : resolvers::dmi_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.bios_vendor = fact::bios_vendor;
        result.bios_version = fact::bios_version;
        result.bios_release_date = fact::bios_release_date;
        result.board_asset_tag = fact::board_asset_tag;
        result.board_manufacturer = fact::board_manufacturer;
        result.board_product_name = fact::board_product_name;
        result.board_serial_number = fact::board_serial_number;
        result.chassis_asset_tag = fact::chassis_asset_tag;
        result.manufacturer = fact::manufacturer;
        result.product_name = fact::product_name;
        result.serial_number = fact::serial_number;
        result.uuid = fact::uuid;
        result.chassis_type = fact::chassis_type;
        return result;
    }
};

struct filesystem_resolver : resolvers::filesystem_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;

        mountpoint mp;
        mp.name = "name";
        mp.device = "device";
        mp.filesystem = "filesystem";
        mp.size = 1234;
        mp.available = 12345;
        mp.options.push_back("option");
        result.mountpoints.emplace_back(move(mp));

        result.filesystems.insert("filesystem");

        partition p;
        p.name = "name";
        p.filesystem = "filesystem";
        p.size = 1234;
        p.uuid = "uuid";
        p.partition_uuid = "partuuid";
        p.label = "label";
        p.partition_label = "partlabel";
        p.mount = "mount";
        result.partitions.emplace_back(move(p));
        return result;
    }
};

struct identity_resolver : resolvers::identity_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.group_id = 123;
        result.group_name = "group";
        result.user_id = 456;
        result.user_name = "user";
        return result;
    }
};

struct kernel_resolver : resolvers::kernel_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.name = "kernel";
        result.release = "1.2.3-kernel";
        result.version = "1.2.3";
        return result;
    }
};

struct load_average_resolver : resolvers::load_average_resolver
{
 protected:
    virtual boost::optional<std::tuple<double, double, double> > get_load_averages() override
    {
        return make_tuple(0.12, 3.45, 6.78);
    }
};

struct memory_resolver : resolvers::memory_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.swap_encryption = encryption_status::encrypted;
        result.mem_total = 10 * 1024 * 1024;
        result.mem_free = 5 * 1024 * 1024;
        result.swap_total = 20 * 1024 * 1024;
        result.swap_free = 4 * 1024 * 1024;
        return result;
    }
};

struct networking_resolver : resolvers::networking_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;

        result.hostname = "hostname";
        result.domain = "domain";
        result.fqdn = "hostname.domain";
        result.primary_interface = "interface1";

        interface iface;
        iface.name = "interface1";
        iface.dhcp_server = "192.168.1.1";
        iface.address.v4 = "127.0.0.1";
        iface.address.v6 = "fe80::1";
        iface.netmask.v4 = "255.0.0.0";
        iface.netmask.v6 = "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff";
        iface.network.v4 = "127.0.0.0";
        iface.network.v6 = "::1";
        iface.macaddress = "00:00:00:00:00:00";
        iface.mtu = 12345;
        result.interfaces.emplace_back(move(iface));
        return result;
    }
};

struct operating_system_resolver : resolvers::operating_system_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.name = "name";
        result.family = "family";
        result.release = "1.2.3";
        result.major = "1.2";
        result.minor = "3";
        result.specification_version = "1.4";
        result.distro.id = "id";
        result.distro.release = "1.2.3";
        result.distro.codename = "codename";
        result.distro.description = "description";
        result.osx.product = "product";
        result.osx.build = "build";
        result.osx.version = "10.10";
        result.win.system32 = "system32";
        result.architecture = "arch";
        result.hardware = "hardware";
        result.selinux.supported = true;
        result.selinux.enabled = true;
        result.selinux.enforced = true;
        result.selinux.current_mode = "current mode";
        result.selinux.config_mode = "config mode";
        result.selinux.config_policy = "config policy";
        result.selinux.policy_version = "policy version";
        return result;
    }
};

struct processor_resolver : resolvers::processor_resolver
{
protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.isa = "isa";
        result.logical_count = 4;
        result.physical_count = 2;
        result.models = {
                "processor1",
                "processor2",
                "processor3",
                "processor4"
        };
        result.speed = 10 * 1000 * 1000 * 1000ull;
        return result;
    }
};

struct ruby_resolver : resolvers::ruby_resolver
{
protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.platform = "platform";
        result.sitedir = "sitedir";
        result.version = "2.1.5";
        return result;
    }
};

struct ssh_resolver : resolvers::ssh_resolver
{
protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.dsa.key = "dsa:key";
        result.dsa.digest.sha1 = "dsa:sha1";
        result.dsa.digest.sha256 = "dsa:sha256";
        result.ecdsa.key = "ecdsa:key";
        result.ecdsa.digest.sha1 = "ecdsa:sha1";
        result.ecdsa.digest.sha256 = "ecdsa:sha256";
        result.ed25519.key = "ed25519:key";
        result.ed25519.digest.sha1 = "ed25519:sha1";
        result.ed25519.digest.sha256 = "ed25519:sha256";
        result.rsa.key = "rsa:key";
        result.rsa.digest.sha1 = "rsa:sha1";
        result.rsa.digest.sha256 = "rsa:sha256";
        return result;
    }
};

struct system_profiler_resolver : resolvers::system_profiler_resolver
{
protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.boot_mode = "boot_mode";
        result.boot_rom_version = "boot_rom_version";
        result.boot_volume = "boot_volume";
        result.processor_name = "processor_name";
        result.processor_speed = "processor_speed";
        result.kernel_version = "kernel_version";
        result.l2_cache_per_core = "l2_cache_per_core";
        result.l3_cache = "l3_cache";
        result.computer_name = "computer_name";
        result.model_identifier = "model_identifier";
        result.model_name = "model_name";
        result.cores = "cores";
        result.system_version = "system_version";
        result.processors = "processors";
        result.memory = "memory";
        result.hardware_uuid = "hardware_uuid";
        result.secure_virtual_memory = "secure_virtual_memory";
        result.serial_number = "serial_number";
        result.smc_version = "smc_version";
        result.uptime = "uptime";
        result.username = "username";
        return result;
    }
};

struct timezone_resolver : resolvers::timezone_resolver
{
protected:
    virtual string get_timezone() override
    {
        return "PDT";
    }
};

struct uptime_resolver : resolvers::uptime_resolver
{
protected:
    virtual int64_t get_uptime() override
    {
        return 1;
    }
};

struct virtualization_resolver : resolvers::virtualization_resolver
{
protected:
    virtual string get_hypervisor(collection& facts) override
    {
        // The xen fact only resolves if virtualization is xen_privileged.
        return vm::xen_privileged;
    }
};

struct xen_resolver : resolvers::xen_resolver
{
protected:
    virtual string xen_command()
    {
        return "";
    }

    virtual data collect_data(collection& facts) override
    {
        data result;
        result.domains = { "domain1", "domain2" };
        return result;
    }
};

struct zfs_resolver : resolvers::zfs_resolver
{
protected:
    virtual string zfs_command()
    {
        return "";
    }

    virtual data collect_data(collection& facts) override
    {
        data result;
        result.version = 1;
        result.features = { "1", "2", "3" };
        return result;
    }
};

struct zone_resolver : resolvers::zone_resolver
{
protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        zone z;
        z.brand = "brand";
        z.id = "id";
        z.ip_type = "ip type";
        z.name = "name";
        z.path = "path";
        z.status = "status";
        z.uuid = "uuid";
        result.zones.emplace_back(move(z));
        result.current_zone_name = "name";
        return result;
    }
};

struct zpool_resolver : resolvers::zpool_resolver
{
protected:
    virtual string zpool_command()
    {
        return "";
    }

    virtual data collect_data(collection& facts) override
    {
        data result;
        result.version = 1;
        result.features = { "1", "2", "3" };
        return result;
    }
};

void add_all_facts(collection& facts)
{
    facts.add("env_windows_installdir", make_value<string_value>("C:\\Program Files\\Some\\Path"));
    facts.add("facterversion", make_value<string_value>("version"));
    facts.add(make_shared<augeas_resolver>());
    facts.add(make_shared<disk_resolver>());
    facts.add(make_shared<dmi_resolver>());
    facts.add(make_shared<filesystem_resolver>());
    // TODO: refactor the EC2 resolver to use the "collect_data" pattern
    facts.add(fact::ec2_metadata, make_value<map_value>());
    facts.add(fact::ec2_userdata, make_value<string_value>("user data"));
    // TODO: refactor the GCE resolver to use the "collect_data" pattern
    facts.add(fact::gce, make_value<map_value>());
    facts.add(make_shared<identity_resolver>());
    facts.add(make_shared<kernel_resolver>());
    facts.add(make_shared<load_average_resolver>());
    facts.add(make_shared<memory_resolver>());
    facts.add(make_shared<networking_resolver>());
    facts.add(make_shared<operating_system_resolver>());
    facts.add(make_shared<resolvers::path_resolver>());
    facts.add(make_shared<processor_resolver>());
    facts.add(make_shared<ruby_resolver>());
    facts.add(make_shared<ssh_resolver>());
    facts.add(make_shared<system_profiler_resolver>());
    facts.add(make_shared<timezone_resolver>());
    facts.add(make_shared<uptime_resolver>());
    facts.add(make_shared<virtualization_resolver>());
    facts.add(make_shared<xen_resolver>());
    facts.add(make_shared<zfs_resolver>());
    facts.add(make_shared<zone_resolver>());
    facts.add(make_shared<zpool_resolver>());
}

void validate_attributes(YAML::Node const& node)
{
    REQUIRE(node.IsMap());

    for (auto const& attribute : node) {
        auto attribute_name = attribute.first.as<string>();
        CAPTURE(attribute_name);
        REQUIRE_THAT(attribute_name, AnyOf(
            Catch::Equals("pattern"),
            Catch::Equals("type")).add(
            Catch::Equals("hidden")).add(
            Catch::Equals("description")).add(
            Catch::Equals("resolution")).add(
            Catch::Equals("caveats")).add(
            Catch::Equals("elements")).add(
            Catch::Equals("validate"))
        );
    }

    // If pattern is present, it must be a non-empty string
    auto pattern_attribute = node["pattern"];
    if (pattern_attribute) {
        REQUIRE(pattern_attribute.IsScalar());
        auto pattern = pattern_attribute.as<string>();
        REQUIRE_FALSE(pattern.empty());
    }

    // Node must have a type attribute
    auto type_attribute = node["type"];
    REQUIRE(type_attribute);
    REQUIRE(type_attribute.IsScalar());
    auto type = type_attribute.as<string>();
    REQUIRE_THAT(type, AnyOf(
        Catch::Equals("integer"),
        Catch::Equals("double")).add(
        Catch::Equals("string")).add(
        Catch::Equals("boolean")).add(
        Catch::Equals("array")).add(
        Catch::Equals("map")).add(
        Catch::Equals("ip")).add(
        Catch::Equals("ip6")).add(
        Catch::Equals("mac"))
    );

    // Check map types
    auto elements = node["elements"];
    if (type == "map") {
        // If the validate attribute is present, it must be true or false
        auto validate_attribute = node["validate"];
        string validate = "true";
        if (validate_attribute) {
            REQUIRE(validate_attribute.IsScalar());
            validate = validate_attribute.as<string>();
            REQUIRE_THAT(validate, AnyOf(Catch::Equals("true"), Catch::Equals("false")));
        }

        // Validated map values must have elements
        if (validate == "true") {
            REQUIRE(elements);
            REQUIRE(elements.IsMap());
        }
    } else {
        REQUIRE_FALSE(elements);

        // There should not be a validate attribute
        auto validate_attribute = node["validate"];
        REQUIRE_FALSE(validate_attribute);
    }

    // If hidden is present, it must be a boolean
    auto hidden_attribute = node["hidden"];
    if (hidden_attribute) {
        REQUIRE(hidden_attribute.IsScalar());
        auto hidden = hidden_attribute.as<string>();
        REQUIRE_THAT(hidden, AnyOf(Catch::Equals("true"), Catch::Equals("false")));
    }

    // Node must have a description attribute
    auto description_attribute = node["description"];
    REQUIRE(description_attribute);
    REQUIRE(description_attribute.IsScalar());
    auto description = description_attribute.as<string>();
    REQUIRE_FALSE(description.empty());

    // If the resolutions is present, it must be a non-empty string
    auto resolutions_attribute = node["resolutions"];
    if (resolutions_attribute) {
        REQUIRE(resolutions_attribute.IsScalar());
        auto resolutions = resolutions_attribute.as<string>();
        REQUIRE_FALSE(resolutions.empty());
    }

    // If the caveats are present, it must be a non-empty string
    auto caveats_attribute = node["caveats"];
    if (caveats_attribute) {
        REQUIRE(caveats_attribute.IsScalar());
        auto caveats = caveats_attribute.as<string>();
        REQUIRE_FALSE(caveats.empty());
    }

    // Recurse on elements
    if (elements) {
        for (auto const& element : elements) {
            auto element_name = element.first.as<string>();
            CAPTURE(element_name);
            validate_attributes(element.second);
        }
    }
}

YAML::Node find_child(YAML::Node const& node, string const& name, set<string>& found)
{
    REQUIRE(node.IsMap());

    for (auto const& child : node) {
        auto child_name = child.first.as<string>();
        auto pattern_attribute = child.second["pattern"];
        if ((pattern_attribute && re_search(name, boost::regex(pattern_attribute.as<string>()))) ||
            child_name == name) {
            found.insert(move(child_name));
            return child.second;
        }
    }

    return YAML::Node(YAML::NodeType::Undefined);
}

void validate_fact(YAML::Node const& node, value const* fact_value, bool require_all_elements)
{
    REQUIRE(node.IsMap());

    // Ensure the types match
    auto type_attribute = node["type"];
    auto expected_type = type_attribute.as<string>();
    string type;
    string_value const* svalue = nullptr;
    map_value const* map = nullptr;
    if (dynamic_cast<integer_value const*>(fact_value)) {
        type = "integer";
    } else if (dynamic_cast<double_value const*>(fact_value)) {
        type = "double";
    } else if ((svalue = dynamic_cast<string_value const*>(fact_value))) {
        type = "string";

        // Check for special string types; sourced from http://stackoverflow.com/a/17871737
        static boost::regex ip_pattern("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$");
        static boost::regex ip6_pattern("^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$");
        static boost::regex mac_pattern("^(([0-9a-fA-F]){2}\\:){5}([0-9a-fA-F]){2}$");

        if (expected_type == "ip" && re_search(svalue->value(), ip_pattern)) {
            type = "ip";
        } else if (expected_type == "ip6" && re_search(svalue->value(), ip6_pattern)) {
            type = "ip6";
        } else if (expected_type == "mac" && re_search(svalue->value(), mac_pattern)) {
            type = "mac";
        }
    } else if (dynamic_cast<boolean_value const*>(fact_value)) {
        type = "boolean";
    } else if (dynamic_cast<array_value const*>(fact_value)) {
        type = "array";
    } else if ((map = dynamic_cast<map_value const*>(fact_value))) {
        type = "map";
    } else {
        FAIL("unexpected fact value type");
    }
    REQUIRE(type == expected_type);

    // Ensure the value is hidden according to the schema
    auto hidden_attribute = node["hidden"];
    bool expected_hidden = hidden_attribute && hidden_attribute.as<string>() == "true";
    bool hidden = fact_value->hidden();
    REQUIRE(hidden == expected_hidden);

    // Recurse on map elements
    if (map) {
        auto elements = node["elements"];

        // Validate the map's elements "validate" is unset or true
        auto validate_attribute = node["validate"];
        if (!validate_attribute || validate_attribute.as<string>() == "true") {
            set<string> found;
            map->each([&](string const& element_name, value const* element_value) {
                if (!element_value) {
                    return true;
                }
                CAPTURE(element_name);
                auto element = find_child(elements, element_name, found);
                REQUIRE(element);
                validate_fact(element, element_value, require_all_elements);
                return true;
            });

            // Require all elements were found
            if (require_all_elements) {
                REQUIRE(found.size() == elements.size());
            }
        }
    }
}

SCENARIO("validating schema") {
    boost::nowide::ifstream stream(LIBFACTER_TESTS_DIRECTORY "/../schema/facter.yaml");

    YAML::Node schema = YAML::Load(stream);
    collection_fixture facts;

    WHEN("validating the schema itself") {
        THEN("all attributes must be valid") {
            for (auto const& fact : schema) {
                auto fact_name = fact.first.as<string>();
                CAPTURE(fact_name);
                validate_attributes(fact.second);
            }
        }
    }
    WHEN("validating a fact collection") {
        THEN("all facts must conform to the schema") {
            add_all_facts(facts);

            set<string> found;

            facts.each([&](string const& fact_name, value const* fact_value) {
                if (!fact_value) {
                    return true;
                }
                CAPTURE(fact_name);
                auto fact = find_child(schema, fact_name, found);
                REQUIRE(fact);
                validate_fact(fact, fact_value, true);
                return true;
            });

            // Require all elements in the schema were found
            REQUIRE(found.size() == schema.size());
        }
        THEN("the current platform's facts must conform to the schema") {
            facts.add_default_facts(true);

            set<string> found;

            facts.each([&](string const& fact_name, value const* fact_value) {
                if (!fact_value) {
                    return true;
                }
                CAPTURE(fact_name);
                auto fact = find_child(schema, fact_name, found);
                REQUIRE(fact);
                validate_fact(fact, fact_value, false);
                return true;
            });
        }
    }
}
