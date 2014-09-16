#include <facter/util/dynamic_library.hpp>
#include <boost/format.hpp>
#include <windows.h>
#include <facter/logging/logging.hpp>
#include <facter/util/windows/scoped_error.hpp>

using namespace std;

LOG_DECLARE_NAMESPACE("util.windows.dynamic_library");

namespace facter { namespace util {

    dynamic_library dynamic_library::find_by_name(std::string const& name)
    {
        // TODO WINDOWS: Implement function.
        return dynamic_library();
    }

    dynamic_library dynamic_library::find_by_symbol(std::string const& symbol)
    {
        // TODO WINDOWS: Implement function with SymFromName.
        // http://msdn.microsoft.com/en-us/library/windows/desktop/ms680580(v=vs.85).aspx
        return dynamic_library();
    }

    bool dynamic_library::load(string const& name)
    {
        close();

        // Check if the module has already been loaded (and increment the ref count).
        HMODULE hMod;
        if (!GetModuleHandleEx(0, TEXT(name.c_str()), &hMod)) {
            // Load now
            hMod = LoadLibrary(TEXT(name.c_str()));
            if (!hMod) {
                auto err = GetLastError();
                LOG_DEBUG("library %1% not found %2% (%3%).", name.c_str(), scoped_error(err), err);
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
