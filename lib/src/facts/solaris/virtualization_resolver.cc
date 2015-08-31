#include <internal/facts/solaris/virtualization_resolver.hpp>
#include <facter/facts/vm.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <map>

using namespace std;
using namespace facter::facts;
using namespace leatherman::util;
using namespace leatherman::execution;

namespace facter { namespace facts { namespace solaris {

    string virtualization_resolver::get_hypervisor(collection& facts)
    {
        // If in an LDom, the LDom facts will resolve and we can use them to identify
        // that we're in a virtual LDom environment. They should only resolve on SPARC.
        auto ldom_domainrole_control = facts.get<string_value>("ldom_domainrole_control");
        if (ldom_domainrole_control && ldom_domainrole_control->value() == "false") {
            auto ldom_domainrole_impl = facts.get<string_value>("ldom_domainrole_impl");
            if (ldom_domainrole_impl) {
                return ldom_domainrole_impl->value();
            }
        }

        // works for both x86 & sparc.
        bool success;
        string output, none;
        tie(success, output, none) = execute("/usr/bin/zonename");
        if (success && output != "global") {
            return vm::zone;
        }

        string guest_of;

        static map<boost::regex, string> virtual_map = {
            {boost::regex("Parallels"),  string(vm::parallels)},
            {boost::regex("VM[wW]are"),  string(vm::vmware)},
            {boost::regex("VirtualBox"), string(vm::virtualbox)},
            {boost::regex("HVM domU"),   string(vm::xen_hardware)},
            {boost::regex("KVM"),        string(vm::kvm)},
            {boost::regex("oVirt Node"), string(vm::ovirt)}
        };

        // Use the same timeout as in Facter 2.x
        const uint32_t timeout = 20;
        try {
            each_line(
                "/usr/sbin/prtdiag",
                [&](string& line) {
                    for (auto const& it : virtual_map) {
                        if (re_search(line, it.first)) {
                            guest_of = it.second;
                            return false;
                        }
                    }
                    return true;
                },
                nullptr,
                timeout);
        } catch (timeout_exception const&) {
            LOG_WARNING("execution of prtdiag has timed out after %1% seconds.", timeout);
        }

        return guest_of;
    }
}}}  // namespace facter::facts::solaris
