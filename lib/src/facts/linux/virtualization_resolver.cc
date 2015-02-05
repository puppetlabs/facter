#include <facter/facts/linux/virtualization_resolver.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/file.hpp>
#include <facter/util/regex.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <vector>
#include <tuple>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace facter::execution;
using namespace boost::filesystem;
namespace bs = boost::system;

namespace facter { namespace facts { namespace linux {

    string virtualization_resolver::get_hypervisor(collection& facts)
    {
        // First check for Docker/LXC
        string value = get_cgroup_vm();

        // Next check for Google Compute Engine
        if (value.empty()) {
            value = get_gce_vm(facts);
        }

        // Next check based on the virt-what command
        if (value.empty()) {
            value = get_what_vm();
        }

        // Next check the vmware tool output
        if (value.empty()) {
            value = get_vmware_vm();
        }

        // Next check for OpenVZ
        if (value.empty()) {
            value = get_openvz_vm();
        }

        // Next check for VServer
        if (value.empty()) {
            value = get_vserver_vm();
        }

        // Next check for Xen
        if (value.empty()) {
            value = get_xen_vm();
        }

        // Next check the DMI product name for the VM
        if (value.empty()) {
            value = get_product_name_vm(facts);
        }

        // Lastly, resort to lspci to look for hardware related to certain VMs
        if (value.empty()) {
            value = get_lspci_vm();
        }

        return value;
    }

    string virtualization_resolver::get_cgroup_vm()
    {
        string value;
        file::each_line("/proc/1/cgroup", [&](string& line) {
            vector<boost::iterator_range<string::iterator>> parts;
            boost::split(parts, line, boost::is_any_of(":"), boost::token_compress_on);
            if (parts.size() < 3) {
                return true;
            }
            if (boost::starts_with(parts[2], boost::as_literal("/docker/"))) {
                value = vm::docker;
                return false;
            }
            if (boost::starts_with(parts[2], boost::as_literal("/lxc/"))) {
                value = vm::lxc;
                return false;
            }
            return true;
        });
        return value;
    }

    string virtualization_resolver::get_gce_vm(collection& facts)
    {
        auto vendor = facts.get<string_value>(fact::bios_vendor);
        if (vendor && vendor->value().find("Google") != string::npos) {
            return vm::gce;
        }
        return {};
    }

    string virtualization_resolver::get_what_vm()
    {
        string value;
        execution::each_line("virt-what", [&](string& line) {
            // Some versions of virt-what dump error/warning messages to stdout
            if (boost::starts_with(line, "virt-what:")) {
                return true;
            }
            // Take the first line that isn't an error/warning
            value = move(line);
            return false;
        });

        // Do some normalization of virt-what's output
        if (!value.empty()) {
            boost::to_lower(value);
            if (value == "linux_vserver") {
                return get_vserver_vm();
            }
            if (value == "xen-hvm") {
                return vm::xen_hardware;
            }
            if (value == "xen-dom0") {
                return vm::xen_privileged;
            }
            if (value == "xen-domu") {
                return vm::xen_unprivileged;
            }
            if (value == "ibm_systemz") {
                return vm::zlinux;
            }
        }
        return value;
    }

    string virtualization_resolver::get_vserver_vm()
    {
        string value;
        file::each_line("/proc/self/status", [&](string& line) {
            vector<boost::iterator_range<string::iterator>> parts;
            boost::split(parts, line, boost::is_space(), boost::token_compress_on);
            if (parts.size() != 2) {
                return true;
            }
            if (parts[0] == boost::as_literal("s_context:") || parts[0] == boost::as_literal("VxID:")) {
                if (parts[1] == boost::as_literal("0")) {
                    value = vm::vserver_host;
                } else {
                    value = vm::vserver;
                }
                return false;
            }
            return true;
        });
        return value;
    }

    string virtualization_resolver::get_vmware_vm()
    {
        auto result = execute("vmware", { "-v" });
        if (!result.first) {
            return {};
        }
        vector<string> parts;
        boost::split(parts, result.second, boost::is_space(), boost::token_compress_on);
        if (parts.size() < 2) {
            return {};
        }
        boost::to_lower(parts[0]);
        boost::to_lower(parts[1]);
        return parts[0] + '_' + parts[1];
    }

    string virtualization_resolver::get_openvz_vm()
    {
        // Detect if it's a OpenVZ without being CloudLinux
        bs::error_code ec;
        if (!is_directory("/proc/vz", ec) ||
            is_regular_file("/proc/lve/list", ec) ||
            boost::filesystem::is_empty("/proc/vz", ec)) {
            return {};
        }
        string value;
        file::each_line("/proc/self/status", [&](string& line) {
            vector<boost::iterator_range<string::iterator>> parts;
            boost::split(parts, line, boost::is_space(), boost::token_compress_on);
            if (parts.size() != 2) {
                return true;
            }
            if (parts[0] == boost::as_literal("envID:")) {
                if (parts[1] == boost::as_literal("0")) {
                    value = vm::openvz_hn;
                } else {
                    value = vm::openvz_ve;
                }
                return false;
            }
            return true;
        });
        return value;
    }

    string virtualization_resolver::get_xen_vm()
    {
        // Check for a required Xen file
        bs::error_code ec;
        if (exists("/dev/xen/evtchn", ec) && !ec) {
            return vm::xen_privileged;
        }
        ec.clear();
        if (exists("/proc/xen", ec) && !ec) {
            return vm::xen_unprivileged;
        }
        ec.clear();
        if (exists("/dev/xvda1", ec) && !ec) {
            return vm::xen_unprivileged;
        }
        return {};
    }

    string virtualization_resolver::get_product_name_vm(collection& facts)
    {
        static vector<tuple<string, string>> vms = {
            make_tuple("VMware",            string(vm::vmware)),
            make_tuple("VirtualBox",        string(vm::virtualbox)),
            make_tuple("Parallels",         string(vm::parallels)),
            make_tuple("KVM",               string(vm::kvm)),
            make_tuple("Virtual Machine",   string(vm::hyperv)),
            make_tuple("RHEV Hypervisor",   string(vm::redhat_ev)),
            make_tuple("oVirt Node",        string(vm::ovirt)),
            make_tuple("HVM domU",          string(vm::xen_hardware)),
            make_tuple("Bochs",             string(vm::bochs)),
        };

        auto product_name = facts.get<string_value>(fact::product_name);
        if (!product_name) {
            return {};
        }

        auto const& value = product_name->value();

        for (auto const& vm : vms) {
            if (value.find(get<0>(vm)) != string::npos) {
                return get<1>(vm);
            }
        }
        return {};
    }

    string virtualization_resolver::get_lspci_vm()
    {
        static vector<tuple<re_adapter, string>> vms = {
            make_tuple("VM[wW]are",                               string(vm::vmware)),
            make_tuple("VirtualBox",                              string(vm::virtualbox)),
            make_tuple("1ab8:|[Pp]arallels",                      string(vm::parallels)),
            make_tuple("XenSource",                               string(vm::xen_hardware)),
            make_tuple("Microsoft Corporation Hyper-V",           string(vm::hyperv)),
            make_tuple("Class 8007: Google, Inc",                 string(vm::gce)),
            make_tuple(re_adapter("virtio", boost::regex::icase), string(vm::kvm)),
        };

        string value;
        execution::each_line("lspci", [&](string& line) {
            for (auto const& vm : vms) {
                if (re_search(line, get<0>(vm))) {
                    value = get<1>(vm);
                    return false;
                }
            }
            return true;
        });
        return value;
    }

}}}  // namespace facter::facts::linux
