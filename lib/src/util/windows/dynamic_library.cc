#include <facter/util/scoped_resource.hpp>
#include <internal/util/regex.hpp>
#include <internal/util/dynamic_library.hpp>
#include <internal/util/windows/system_error.hpp>
#include <internal/util/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/format.hpp>
#include <boost/nowide/convert.hpp>
#include <tlhelp32.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;

namespace facter { namespace util {

    dynamic_library dynamic_library::find_by_pattern(std::string const& pattern)
    {
        dynamic_library library;

        // Check to see if the library is loaded. Walk the list of loaded modules and match against pattern.
        // See http://msdn.microsoft.com/en-us/library/windows/desktop/ms686849(v=vs.85).aspx for details on
        // the Tool Help library.
        HANDLE hModuleSnap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, GetCurrentProcessId());
        if (hModuleSnap == INVALID_HANDLE_VALUE) {
            LOG_DEBUG("library matching pattern %1% not found, CreateToolhelp32Snapshot failed: %2%.", pattern.c_str(), system_error());
            return library;
        }
        scoped_resource<HANDLE> hModSnap(hModuleSnap, CloseHandle);

        MODULEENTRY32 me32 = {};
        me32.dwSize = sizeof(MODULEENTRY32);
        if (!Module32First(hModSnap, &me32)) {
            LOG_DEBUG("library matching pattern %1% not found, Module32First failed: %2%.", pattern.c_str(), system_error());
            return library;
        }

        boost::regex rx(pattern);
        do {
            if (re_search(boost::nowide::narrow(me32.szModule), rx)) {
                // Use GetModuleHandleEx to ensure the reference count is incremented. If the module has been
                // unloaded since the snapshot was made, this may fail and we should return an empty library.
                HMODULE hMod;
                if (GetModuleHandleEx(0, me32.szModule, &hMod)) {
                    library._handle = hMod;
                    library._first_load = false;
                    LOG_DEBUG("library %1% found from pattern %2%", me32.szModule, pattern);
                } else {
                    LOG_DEBUG("library %1% found from pattern %2%, but unloaded before handle was acquired", me32.szModule, pattern);
                }
                return library;
            }
        } while (Module32Next(hModSnap, &me32));

        LOG_DEBUG("no loaded libraries found matching pattern %1%", pattern);
        return library;
    }

    dynamic_library dynamic_library::find_by_symbol(std::string const& symbol)
    {
        // Windows doesn't have this capability.
        return dynamic_library();
    }

    bool dynamic_library::load(string const& name)
    {
        close();

        // Check if the module has already been loaded (and increment the ref count).
        HMODULE hMod;
        auto wname = boost::nowide::widen(name);
        if (!GetModuleHandleExW(0, wname.c_str(), &hMod)) {
            // Load now
            hMod = LoadLibraryW(wname.c_str());
            if (!hMod) {
                LOG_DEBUG("library %1% not found %2%.", name.c_str(), system_error());
                return false;
            }
            _first_load = true;
        }
        _handle = hMod;
        _name = name;
        return true;
    }

    void dynamic_library::close()
    {
        if (_handle) {
            FreeLibrary(static_cast<HMODULE>(_handle));
            _handle = nullptr;
        }
        _name.clear();
        _first_load = false;
    }

    void* dynamic_library::find_symbol(string const& name, bool throw_if_missing, string const& alias) const
    {
        if (!_handle) {
            if (throw_if_missing) {
                throw missing_import_exception("library is not loaded");
            } else {
                LOG_DEBUG("library %1% is not loaded when attempting to load symbol %2%.", _name.c_str(), name.c_str());
            }
            return nullptr;
        }
        auto symbol = GetProcAddress(static_cast<HMODULE>(_handle), name.c_str());
        if (!symbol && !alias.empty()) {
            LOG_DEBUG("symbol %1% not found in library %2%, trying alias %3%.", name.c_str(), _name.c_str(), alias.c_str());
            symbol = GetProcAddress(static_cast<HMODULE>(_handle), alias.c_str());
        }
        if (!symbol) {
            if (throw_if_missing) {
                throw missing_import_exception((boost::format("symbol %1% was not found in %2%.") %name %_name).str());
            } else {
                LOG_DEBUG("symbol %1% not found in library %2%.", name.c_str(), _name.c_str());
            }
        }
        return reinterpret_cast<void *>(symbol);
    }

}}  // namespace facter::util
