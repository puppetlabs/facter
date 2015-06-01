#include <catch.hpp>
#include <internal/facts/resolvers/operating_system_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/map_value.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::facts::resolvers;

struct empty_os_resolver : operating_system_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        return {};
    }
};

struct test_os_resolver : operating_system_resolver
{
 protected:
    virtual data collect_data(collection& facts) override
    {
        data result;
        result.name = "Archlinux";
        result.family = "Archlinux";
        result.release = "1.2.3";
        result.major = "1";
        result.minor = "2";
        result.specification_version = "1.4";
        result.distro.id = "Arch";
        result.distro.release = "1.2.3";
        result.distro.codename = "awesomesauce";
        result.distro.description = "best distro ever";
        result.osx.product = "Mac OS X";
        result.osx.build = "14A388b";
        result.osx.version = "10.10";
        result.win.system32 = "C:\\WINDOWS\\sysnative";
        result.architecture = "amd64";
        result.hardware = "x86-64";
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

SCENARIO("using the operating system resolver") {
    collection facts;
    WHEN("data is not present") {
        facts.add(make_shared<empty_os_resolver>());
        THEN("facts should not be added") {
            REQUIRE(facts.size() == 0);
        }
    }
    WHEN("data is present") {
        facts.add(make_shared<test_os_resolver>());
        REQUIRE(facts.size() == 26);
        THEN("a structured fact is added") {
            auto os = facts.get<map_value>(fact::os);
            REQUIRE(os);
            REQUIRE(os->size() == 9);
            auto distro = os->get<map_value>("distro");
            REQUIRE(distro);
            REQUIRE(distro->size() == 5);
            auto codename = distro->get<string_value>("codename");
            REQUIRE(codename);
            REQUIRE(codename->value() == "awesomesauce");
            auto description = distro->get<string_value>("description");
            REQUIRE(description);
            REQUIRE(description->value() == "best distro ever");
            auto id = distro->get<string_value>("id");
            REQUIRE(description);
            REQUIRE(id->value() == "Arch");
            auto lsbrelease = distro->get<string_value>("specification");
            REQUIRE(lsbrelease);
            REQUIRE(lsbrelease->value() == "1.4");
            auto release_attribute = distro->get<map_value>("release");
            REQUIRE(release_attribute);
            REQUIRE(release_attribute->size() == 3);
            auto release = release_attribute->get<string_value>("full");
            REQUIRE(release);
            REQUIRE(release->value() == "1.2.3");
            auto major = release_attribute->get<string_value>("major");
            REQUIRE(major);
            REQUIRE(major->value() == "1");
            auto minor = release_attribute->get<string_value>("minor");
            REQUIRE(minor);
            REQUIRE(minor->value() == "2");
            auto family = os->get<string_value>("family");
            REQUIRE(family);
            REQUIRE(family->value() == "Archlinux");
            auto name = os->get<string_value>("name");
            REQUIRE(name);
            REQUIRE(name->value() == "Archlinux");
            auto architecture = os->get<string_value>("architecture");
            REQUIRE(architecture);
            REQUIRE(architecture->value() == "amd64");
            auto hardware = os->get<string_value>("hardware");
            REQUIRE(hardware);
            REQUIRE(hardware->value() == "x86-64");
            release_attribute = os->get<map_value>("release");
            REQUIRE(release_attribute);
            REQUIRE(release_attribute->size() == 3);
            release = release_attribute->get<string_value>("full");
            REQUIRE(release);
            REQUIRE(release->value() == "1.2.3");
            major = release_attribute->get<string_value>("major");
            REQUIRE(major);
            REQUIRE(major->value() == "1");
            minor = release_attribute->get<string_value>("minor");
            REQUIRE(minor);
            REQUIRE(minor->value() == "2");
            auto macosx = os->get<map_value>("macosx");
            REQUIRE(macosx);
            REQUIRE(macosx->size() == 3);
            auto product = macosx->get<string_value>("product");
            REQUIRE(product);
            REQUIRE(product->value() == "Mac OS X");
            auto build = macosx->get<string_value>("build");
            REQUIRE(build);
            REQUIRE(build->value() == "14A388b");
            release_attribute = macosx->get<map_value>("version");
            REQUIRE(release_attribute);
            REQUIRE(release_attribute->size() == 3);
            release = release_attribute->get<string_value>("full");
            REQUIRE(release);
            REQUIRE(release->value() == "10.10");
            major = release_attribute->get<string_value>("major");
            REQUIRE(major);
            REQUIRE(major->value() == "10.10");
            minor = release_attribute->get<string_value>("minor");
            REQUIRE(minor);
            REQUIRE(minor->value() == "0");
            auto windows = os->get<map_value>("windows");
            REQUIRE(windows);
            REQUIRE(windows->size() == 1);
            auto system32 = windows->get<string_value>("system32");
            REQUIRE(system32);
            REQUIRE(system32->value() == "C:\\WINDOWS\\sysnative");
            auto selinux = os->get<map_value>("selinux");
            REQUIRE(selinux);
            REQUIRE(selinux->size() == 6);
            auto bval = selinux->get<boolean_value>("enabled");
            REQUIRE(bval);
            REQUIRE(bval->value());
            bval = selinux->get<boolean_value>("enforced");
            REQUIRE(bval);
            REQUIRE(bval->value());
            auto sval = selinux->get<string_value>("policy_version");
            REQUIRE(sval);
            REQUIRE(sval->value() == "policy version");
            sval = selinux->get<string_value>("current_mode");
            REQUIRE(sval);
            REQUIRE(sval->value() == "current mode");
            sval = selinux->get<string_value>("config_mode");
            REQUIRE(sval);
            REQUIRE(sval->value() == "config mode");
            sval = selinux->get<string_value>("config_policy");
            REQUIRE(sval);
            REQUIRE(sval->value() == "config policy");
        }
        THEN("flat facts are added") {
            auto name = facts.get<string_value>(fact::operating_system);
            REQUIRE(name);
            REQUIRE(name->value() == "Archlinux");
            auto architecture = facts.get<string_value>(fact::architecture);
            REQUIRE(architecture);
            REQUIRE(architecture->value() == "amd64");
            auto hardware = facts.get<string_value>(fact::hardware_model);
            REQUIRE(hardware);
            REQUIRE(hardware->value() == "x86-64");
            auto release = facts.get<string_value>(fact::operating_system_release);
            REQUIRE(release);
            REQUIRE(release->value() == "1.2.3");
            auto major = facts.get<string_value>(fact::operating_system_major_release);
            REQUIRE(major);
            REQUIRE(major->value() == "1");
            auto family = facts.get<string_value>(fact::os_family);
            REQUIRE(family);
            REQUIRE(family->value() == "Archlinux");
            auto codename = facts.get<string_value>(fact::lsb_dist_codename);
            REQUIRE(codename);
            REQUIRE(codename->value() == "awesomesauce");
            auto description = facts.get<string_value>(fact::lsb_dist_description);
            REQUIRE(description);
            REQUIRE(description->value() == "best distro ever");
            auto id = facts.get<string_value>(fact::lsb_dist_id);
            REQUIRE(id);
            REQUIRE(id->value() == "Arch");
            release = facts.get<string_value>(fact::lsb_dist_release);
            REQUIRE(release);
            REQUIRE(release->value() == "1.2.3");
            major = facts.get<string_value>(fact::lsb_dist_major_release);
            REQUIRE(major);
            REQUIRE(major->value() == "1");
            auto minor = facts.get<string_value>(fact::lsb_dist_minor_release);
            REQUIRE(minor);
            REQUIRE(minor->value() == "2");
            auto lsbrelease = facts.get<string_value>(fact::lsb_release);
            REQUIRE(lsbrelease);
            REQUIRE(lsbrelease->value() == "1.4");
            auto build = facts.get<string_value>(fact::macosx_buildversion);
            REQUIRE(build);
            REQUIRE(build->value() == "14A388b");
            auto product = facts.get<string_value>(fact::macosx_productname);
            REQUIRE(product);
            REQUIRE(product->value() == "Mac OS X");
            release = facts.get<string_value>(fact::macosx_productversion);
            REQUIRE(release);
            REQUIRE(release->value() == "10.10");
            major = facts.get<string_value>(fact::macosx_productversion_major);
            REQUIRE(major);
            REQUIRE(major->value() == "10.10");
            minor = facts.get<string_value>(fact::macosx_productversion_minor);
            REQUIRE(minor);
            REQUIRE(minor->value() == "0");
            auto system32 = facts.get<string_value>(fact::windows_system32);
            REQUIRE(system32);
            REQUIRE(system32->value() == "C:\\WINDOWS\\sysnative");
            auto bval = facts.get<boolean_value>(fact::selinux);
            REQUIRE(bval);
            REQUIRE(bval->value());
            bval = facts.get<boolean_value>(fact::selinux_enforced);
            REQUIRE(bval);
            REQUIRE(bval->value());
            auto sval = facts.get<string_value>(fact::selinux_policyversion);
            REQUIRE(sval);
            REQUIRE(sval->value() == "policy version");
            sval = facts.get<string_value>(fact::selinux_current_mode);
            REQUIRE(sval);
            REQUIRE(sval->value() == "current mode");
            sval = facts.get<string_value>(fact::selinux_config_mode);
            REQUIRE(sval);
            REQUIRE(sval->value() == "config mode");
            sval = facts.get<string_value>(fact::selinux_config_policy);
            REQUIRE(sval);
            REQUIRE(sval->value() == "config policy");
        }
    }
}
