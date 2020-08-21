#include <leatherman/dynamic_library/dynamic_library.hpp>
#include <internal/facts/windows/kernel_resolver.hpp>
#include <facter/facts/os.hpp>
#include <leatherman/logging/logging.hpp>

#include <boost/optional.hpp>
#include <boost/format.hpp>
#include <windows.h>
#include <ntstatus.h>

using namespace std;
using namespace leatherman::dynamic_library;
using RtlGetVersionPtr = NTSTATUS (WINAPI *)(PRTL_OSVERSIONINFOW);

namespace facter { namespace facts { namespace windows {

    static boost::optional<string> get_release()
    {
        dynamic_library ntdll;
        if (! ntdll.load("ntdll.dll")) {
          return boost::none;
        }

        auto rtlGetVersion = reinterpret_cast<RtlGetVersionPtr>(
            ntdll.find_symbol("RtlGetVersion"));
        if (! rtlGetVersion) {
          return boost::none;
        }

        OSVERSIONINFOW versionInfo;
        if (rtlGetVersion(&versionInfo) != STATUS_SUCCESS) {
          LOG_DEBUG("failed to get the OS version information from RtlGetVersion");
          return boost::none;
        }

        auto versionStr = (boost::format("%1%.%2%.%3%")
            % versionInfo.dwMajorVersion
            % versionInfo.dwMinorVersion
            % versionInfo.dwBuildNumber).str();

        return versionStr;
    }

    kernel_resolver::data kernel_resolver::collect_data(collection& facts)
    {
        data result;

        auto release = get_release();
        if (release) {
            result.release = move(*release);
            result.version = result.release;
        }

        result.name = os::windows;
        return result;
    }

}}}  // namespace facter::facts::windows
