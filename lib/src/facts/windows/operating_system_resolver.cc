#include <internal/facts/windows/operating_system_resolver.hpp>
#include <leatherman/windows/registry.hpp>
#include <leatherman/windows/system_error.hpp>
#include <leatherman/windows/wmi.hpp>
#include <leatherman/windows/windows.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/os_family.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/util/regex.hpp>
#include <intrin.h>
#include <winnt.h>
#include <Shlobj.h>
#include <map>
#include <string>
#include <boost/filesystem.hpp>

using namespace std;
using namespace leatherman::util;
using namespace leatherman::windows;
using namespace boost::filesystem;

namespace facter { namespace facts { namespace windows {

    static string get_hardware()
    {
        SYSTEM_INFO sysInfo;
        GetNativeSystemInfo(&sysInfo);

        switch (sysInfo.wProcessorArchitecture) {
            case PROCESSOR_ARCHITECTURE_AMD64:
                return "x86_64";
            case PROCESSOR_ARCHITECTURE_ARM:
                return "arm";
            case PROCESSOR_ARCHITECTURE_IA64:
                return "ia64";
            case PROCESSOR_ARCHITECTURE_INTEL:
                return "i" + to_string((sysInfo.wProcessorLevel > 5) ? 6 : sysInfo.wProcessorLevel) + "86";
            default:
                return "unknown";
        }
    }

    static string get_architecture(string const& hardware)
    {
        // Use "x86" for 32-bit systems
        if (re_search(hardware, boost::regex("i[3456]86"))) {
            return "x86";
        } else if (hardware == "x86_64") {
            return "x64";
        }
        return hardware;
    }

    static string get_system32()
    {
        // When facter is a 32-bit process running on 64-bit windows (such as in a 32-bit puppet installation that
        // includes native facter), system32 points to 32-bit executables; Windows invisibly redirects it. It also
        // provides a link at %SYSTEMROOT%\sysnative for the 64-bit versions. Return the system path where OS-native
        // executables can be found.
        BOOL isWow = FALSE;
        if (!IsWow64Process(GetCurrentProcess(), &isWow)) {
            LOG_DEBUG("Could not determine if we are running in WOW64: {1}", leatherman::windows::system_error());
        }

        if (isWow) {
            TCHAR szPath[MAX_PATH];
            if (!SUCCEEDED(SHGetFolderPath(NULL, CSIDL_WINDOWS, NULL, 0, szPath))) {
                LOG_DEBUG("error finding SYSTEMROOT: {1}", leatherman::windows::system_error());
            }
            return ((path(szPath) / "sysnative").string());
        } else {
            TCHAR szWPath[MAX_PATH];
            if (!SUCCEEDED(SHGetFolderPath(NULL, CSIDL_SYSTEM, NULL, 0, szWPath))) {
                LOG_DEBUG("error finding Windows System folder: {1}", leatherman::windows::system_error());
            }
            return (path(szWPath).string());
        }
    }

    static string get_release_id()
    {
        string releaseID;
        try {
            releaseID = registry::get_registry_string(registry::HKEY::LOCAL_MACHINE,
                "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\", "ReleaseId");
        } catch (registry_exception &e) {
            LOG_DEBUG("failure getting ReleaseId: {1}", e.what());
        }
        return releaseID;
    }

    static string get_edition_id()
    {
        string editionID;
        try {
            editionID = registry::get_registry_string(registry::HKEY::LOCAL_MACHINE,
                "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\", "EditionID");
        } catch (registry_exception &e) {
            LOG_DEBUG("failure getting EditionID: {1}", e.what());
        }
        return editionID;
    }

    static string get_installation_type()
    {
        string installation_type;
        try {
            installation_type = registry::get_registry_string(registry::HKEY::LOCAL_MACHINE,
                "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\", "InstallationType");
        } catch (registry_exception &e) {
            LOG_DEBUG("failure getting InstallationType: {1}", e.what());
        }
        return installation_type;
    }

    static string get_product_name()
    {
        string product_name;
        try {
            product_name = registry::get_registry_string(registry::HKEY::LOCAL_MACHINE,
                "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\", "ProductName");
        } catch (registry_exception &e) {
            LOG_DEBUG("failure getting ProductName: {1}", e.what());
        }
        return product_name;
    }


    operating_system_resolver::operating_system_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::operating_system_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        data result = resolvers::operating_system_resolver::collect_data(facts);

        result.family = os_family::windows;
        result.hardware = get_hardware();
        result.architecture = get_architecture(result.hardware);
        result.win.system32 = get_system32();
        result.win.release_id = get_release_id();
        result.win.edition_id = get_edition_id();
        result.win.installation_type = get_installation_type();
        result.win.product_name = get_product_name();

        auto lastDot = result.release.rfind('.');
        if (lastDot == string::npos) {
            return result;
        }

        auto vals = _wmi->query(wmi::operatingsystem, {wmi::producttype, wmi::othertypedescription});
        if (vals.empty()) {
            return result;
        }

        // Override default release with Windows release names
        auto version = result.release.substr(0, lastDot);
        bool consumerrel = (wmi::get(vals, wmi::producttype) == "1");
        if (version == "10.0") {
            // Calculate the build number to distinguish between
            // Windows Server 2016 and 2019. Note that the kernel
            // version is written as <major>.<minor>.<build_number>
            auto kernel_version_fact = facts.get<string_value>(fact::kernel_version);
            if (! kernel_version_fact) {
                LOG_DEBUG("Could not resolve the OS release and OS major version facts from the kernel version fact");
                return result;
            }
            auto kernel_version = kernel_version_fact->value();
            auto build_number_as_str = kernel_version.substr(
                kernel_version.find_last_of('.') + 1);
            auto build_number = stol(build_number_as_str);

            if (consumerrel) {
              result.release = "10";
            } else if (build_number >= 17623L) {
              result.release = "2019";
            } else {
              result.release = "2016";
            }
        } else if (version == "6.3") {
            result.release = consumerrel ? "8.1" : "2012 R2";
        } else if (version == "6.2") {
            result.release = consumerrel ? "8" : "2012";
        } else if (version == "6.1") {
            result.release = consumerrel ? "7" : "2008 R2";
        } else if (version == "6.0") {
            result.release = consumerrel ? "Vista" : "2008";
        } else if (version == "5.2") {
            if (consumerrel) {
                result.release = "XP";
            } else {
                result.release = (wmi::get(vals, wmi::othertypedescription) == "R2") ? "2003 R2" : "2003";
            }
        }
        result.major = result.release;

        return result;
    }

}}}  // namespace facter::facts::windows
