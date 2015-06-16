#include <internal/facts/windows/operating_system_resolver.hpp>
#include <internal/util/regex.hpp>
#include <leatherman/windows/system_error.hpp>
#include <leatherman/windows/wmi.hpp>
#include <leatherman/windows/windows.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/os_family.hpp>
#include <leatherman/logging/logging.hpp>
#include <intrin.h>
#include <winnt.h>
#include <Shlobj.h>
#include <map>
#include <boost/filesystem.hpp>

using namespace std;
using namespace facter::util;
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
        TCHAR szPath[MAX_PATH];
        if (!SUCCEEDED(SHGetFolderPath(NULL, CSIDL_WINDOWS, NULL, 0, szPath))) {
            LOG_DEBUG("error finding SYSTEMROOT: %1%", system_error());
        }

        auto pathNative = path(szPath) / "sysnative";
        boost::system::error_code ec;
        if (is_directory(pathNative, ec)) {
            return pathNative.string();
        }

        LOG_TRACE("sysnative path does not exist");
        auto path32 = path(szPath) / "system32";
        return path32.string();
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
        if (version == "6.4") {
            result.release = consumerrel ? "10" : result.release;
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
