#include <facter/facts/windows/processor_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/windows/scoped_error.hpp>
#include <facter/util/windows/wmi.hpp>
#include <boost/range/irange.hpp>
#include <boost/range/iterator_range.hpp>
#include <boost/algorithm/string/trim.hpp>
#include <windows.h>
#include <intrin.h>
#include <winnt.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.windows.processor"

namespace facter { namespace facts { namespace windows {

    processor_resolver::processor_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::processor_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    static string get_hardware()
    {
        // IsWow64Process is not available on all supported versions of Windows.
        // Use GetModuleHandle to get a handle to the DLL that contains the function
        // and GetProcAddress to get a pointer to the function if available.
        typedef BOOL (WINAPI *LPFN_ISWOW64PROCESS) (HANDLE, PBOOL);

        BOOL isWow64 = FALSE;
        LPFN_ISWOW64PROCESS fnIsWow64Process = (LPFN_ISWOW64PROCESS)
            GetProcAddress(GetModuleHandle(TEXT("kernel32")), "IsWow64Process");
        if (nullptr != fnIsWow64Process) {
            if (!fnIsWow64Process(GetCurrentProcess(), &isWow64)) {
                auto err = GetLastError();
                LOG_DEBUG("failure determining whether current process is WOW64, defaulting to false"
                    ": %1% (%2%)", scoped_error(err), err);
            }
        }

        SYSTEM_INFO sysInfo;
        GetNativeSystemInfo(&sysInfo);

        // The cryptic windows cpu architecture models are documented in these places:
        //   http://source.winehq.org/source/include/winnt.h#L568
        //   http://msdn.microsoft.com/en-us/library/windows/desktop/aa394373(v=vs.85).aspx
        //   http://msdn.microsoft.com/en-us/library/windows/desktop/windows.system.processorarchitecture.aspx
        //   http://linux.derkeiler.com/Mailing-Lists/Kernel/2008-05/msg12924.html (anything over 6 is still i686)
        // Also, arm and neutral are included because they are valid for the upcoming
        // windows 8 release.  --jeffweiss 23 May 2012
        auto archLevel = (sysInfo.wProcessorLevel > 5) ? 6 : sysInfo.wProcessorLevel;
        switch (sysInfo.wProcessorArchitecture) {
            case PROCESSOR_ARCHITECTURE_NEUTRAL:        return "neutral";
            case PROCESSOR_ARCHITECTURE_IA32_ON_WIN64:  return "i686";
            case PROCESSOR_ARCHITECTURE_AMD64:          return isWow64 ? "i" + to_string(archLevel) + "86" : "x64";
            case PROCESSOR_ARCHITECTURE_MSIL:           return "msil";
            case PROCESSOR_ARCHITECTURE_ALPHA64:        return "alpha64";
            case PROCESSOR_ARCHITECTURE_IA64:           return "ia64";
            case PROCESSOR_ARCHITECTURE_ARM:            return "arm";
            case PROCESSOR_ARCHITECTURE_SHX:            return "shx";
            case PROCESSOR_ARCHITECTURE_PPC:            return "powerpc";
            case PROCESSOR_ARCHITECTURE_ALPHA:          return "alpha";
            case PROCESSOR_ARCHITECTURE_MIPS:           return "mips";
            case PROCESSOR_ARCHITECTURE_INTEL:          return "i" + to_string(archLevel) + "86";
            default: return "unknown";  // PROCESSOR_ARCHITECTURE_UNKNOWN
        }
    }

    static string get_architecture(string const& hardware)
    {
        // For most, the architecture is the same as the model.
        // For others /(i[3456]86|pentium)/, use x86
        if (re_search(hardware, "i[3456]86|pentium")) {
            return "x86";
        } else {
            return hardware;
        }
    }

    // Returns physical_count, logical_count, models, speed
    static tuple<int, int, vector<string>, int64_t> get_processors(wmi const& _wmi)
    {
        vector<string> models;
        int logical_count = 0;

        auto vals = _wmi.query(wmi::processor, {wmi::numberoflogicalprocessors, wmi::name});

        auto num_logical_procs = boost::make_iterator_range(vals.equal_range(wmi::numberoflogicalprocessors));
        if (num_logical_procs.empty()) {
            logical_count = 1;
        } else {
            for (auto const& kv : num_logical_procs) {
                logical_count += stoi(kv.second);
            }
        }

        auto proc_names = boost::make_iterator_range(vals.equal_range(wmi::name));
        for (auto const& kv : proc_names) {
            models.emplace_back(boost::trim_copy(kv.second));
        }

        return make_tuple(models.size(), logical_count, move(models), 0);
    }

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        data result;

        result.hardware = get_hardware();
        result.architecture = get_architecture(result.hardware);
        tie(result.physical_count, result.logical_count, result.models, result.speed) = get_processors(*_wmi);

        return result;
    }

}}}  // namespace facter::facts::windows
