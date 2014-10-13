#include <facter/facts/windows/processor_resolver.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/windows/scoped_error.hpp>
#include <boost/range/irange.hpp>
#include <windows.h>
#include <intrin.h>
#include <winnt.h>

using namespace std;
using namespace facter::util;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.windows.processor"

namespace facter { namespace facts { namespace windows {

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

    // Returns error, physical_count, logical_count, models, speed
    static tuple<bool, int, int, vector<string>, int64_t> get_processors()
    {
        vector<string> models;
        int physical_count = 0, logical_count = 0;

        DWORD returnLength = 0;
        GetLogicalProcessorInformation(nullptr, &returnLength);

        if (GetLastError() != ERROR_INSUFFICIENT_BUFFER) {
            return make_tuple(true, 0, 0, models, 0);
        }

        if (returnLength % sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION) != 0) {
            LOG_DEBUG("unexpected length %1% returned by GetLogicalProcessorInformation", returnLength);
        }

        vector<SYSTEM_LOGICAL_PROCESSOR_INFORMATION> buffer(returnLength/sizeof(SYSTEM_LOGICAL_PROCESSOR_INFORMATION));
        if (!GetLogicalProcessorInformation(buffer.data(), &returnLength)) {
            return make_tuple(true, 0, 0, models, 0);
        }

        for (auto &procInfoEntry : buffer) {
            switch (procInfoEntry.Relationship) {
                case RelationProcessorCore:
                    ++physical_count;
                    // A hyperthreaded core supplies more than one logical processor.
                    // Use std::bitset::count for optimized counting of the number of toggled bits.
                    logical_count += bitset<sizeof(decltype(procInfoEntry.ProcessorMask))*8>
                        (procInfoEntry.ProcessorMask).count();
                    break;
                case RelationNumaNode:
                    LOG_TRACE("skipping NUMA node in SYSTEM_LOGICAL_PROCESSOR_INFORMATION");
                    break;
                case RelationCache:
                    LOG_TRACE("skipping relation cache in SYSTEM_LOGICAL_PROCESSOR_INFORMATION");
                    break;
                case RelationProcessorPackage:
                    LOG_TRACE("skipping processor package in SYSTEM_LOGICAL_PROCESSOR_INFORMATION");
                    break;
                default:
                    LOG_TRACE("unsupported LOGICAL_PROCESSOR_RELATIONSHIP value");
                    break;
            }
        }

        // Query __cpuid for model names; this seems to be black magic dependent on the instruction set.
        // We follow the example at http://msdn.microsoft.com/en-US/library/hskdteyh(v=vs.80).aspx, which supports x86/x64.
        // We only need the brand string to fill models.
        int cpui[4] = {-1};
        __cpuid(cpui, 0x80000000);
        char cpu_brand_string[0x40] = {};

        unsigned int nExIds = cpui[0];
        for (auto i : boost::irange(0x80000000, nExIds+1u)) {
            __cpuid(cpui, i);
            switch (i) {
                case 0x80000002:
                    memcpy(cpu_brand_string, cpui, sizeof(cpui));
                    break;
                case 0x80000003:
                    memcpy(cpu_brand_string+16, cpui, sizeof(cpui));
                    break;
                case 0x80000004:
                    memcpy(cpu_brand_string+32, cpui, sizeof(cpui));
                    break;
                default:
                    break;
            }
        }

        if (nExIds >= 0x80000002) {
            models.assign(physical_count, cpu_brand_string);
        } else {
            LOG_DEBUG("processor models could not be determined using __cpuid");
        }

        return make_tuple(false, physical_count, logical_count, move(models), 0);
    }

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        data result;

        result.hardware = get_hardware();
        result.architecture = get_architecture(result.hardware);
        bool errored;
        tie(errored, result.physical_count, result.logical_count, result.models, result.speed) = get_processors();
        if (errored) {
            auto err = GetLastError();
            LOG_DEBUG("failure querying logical processor information: %1% (%2%)", scoped_error(err), err);
        }

        return result;
    }

}}}  // namespace facter::facts::windows
