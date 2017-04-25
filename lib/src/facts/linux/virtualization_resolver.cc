#include <internal/facts/linux/virtualization_resolver.hpp>
#include <internal/util/agent.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace facter::util;
using namespace leatherman::util;
using namespace leatherman::execution;
using namespace boost::filesystem;

namespace bs = boost::system;
namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace linux {

    string virtualization_resolver::get_cloud_provider(collection& facts)
    {
        // Check for Azure
        std::string provider = get_azure(facts);

        return provider;
    }

    string virtualization_resolver::get_azure(collection& facts, string const& leases_file)
    {
        std::string provider;
        if (boost::filesystem::exists(leases_file))
        {
            lth_file::each_line(leases_file, [&](string& line) {
                // Search for DHCP option 245. This is an accepted method of determining
                // whether a machine is running inside Azure. Source:
                // https://social.msdn.microsoft.com/Forums/azure/en-US/f7fbbee6-370a-41c2-a384-d14ab2a0ac12/what-is-the-correct-method-in-linux-on-azure-to-test-if-you-are-an-azure-vm-?forum=WAVirtualMachinesforWindows
                if (line.find("option 245") != std::string::npos ||
                        line.find("option unknown-245") != std::string::npos) {
                    provider = "azure";
                    return false;
                }
                return true;
            });
        }
        return provider;
    }

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
            auto product_name = facts.get<string_value>(fact::product_name);
            if (product_name) {
                value = get_product_name_vm(product_name->value());
            }
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
        lth_file::each_line("/proc/1/cgroup", [&](string& line) {
            vector<boost::iterator_range<string::iterator>> parts;
            boost::split(parts, line, boost::is_any_of(":"), boost::token_compress_on);
            if (parts.size() < 3) {
                return true;
            }
            if (boost::contains(parts[2], boost::as_literal("/docker"))) {
                value = vm::docker;
                return false;
            }
            if (boost::contains(parts[2], boost::as_literal("/lxc"))) {
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
        string virt_what = agent::which("virt-what");
        string value;
        each_line(virt_what, [&](string& line) {
            // Some versions of virt-what dump error/warning messages to stdout
            if (boost::starts_with(line, "virt-what:")) {
                return true;
            }
            // Take the first line that isn't an error/warning
            // unless it's "xen", in which case we expect a second
            // line with more useful information
            if (line == "xen") {
                return true;
            }
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
        lth_file::each_line("/proc/self/status", [&](string& line) {
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
        auto exec = execute("vmware", { "-v" });
        if (!exec.success) {
            return {};
        }
        vector<string> parts;
        boost::split(parts, exec.output, boost::is_space(), boost::token_compress_on);
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
        lth_file::each_line("/proc/self/status", [&](string& line) {
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

    string virtualization_resolver::get_lspci_vm()
    {
        static vector<tuple<boost::regex, string>> vms = {
            make_tuple(boost::regex("VM[wW]are"),                     string(vm::vmware)),
            make_tuple(boost::regex("VirtualBox"),                    string(vm::virtualbox)),
            make_tuple(boost::regex("1ab8:|[Pp]arallels"),            string(vm::parallels)),
            make_tuple(boost::regex("XenSource"),                     string(vm::xen_hardware)),
            make_tuple(boost::regex("Microsoft Corporation Hyper-V"), string(vm::hyperv)),
            make_tuple(boost::regex("Class 8007: Google, Inc"),       string(vm::gce)),
            make_tuple(boost::regex("[Vv]irtio", boost::regex::icase),   string(vm::kvm)),
        };

        string value;
        each_line("lspci", [&](string& line) {
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
