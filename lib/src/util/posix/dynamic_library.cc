#include <facter/util/dynamic_library.hpp>
#include <dlfcn.h>
#include <boost/format.hpp>
#include <facter/logging/logging.hpp>

using namespace std;

LOG_DECLARE_NAMESPACE("dynamic_library");

namespace facter { namespace util {

    dynamic_library dynamic_library::find_by_name(std::string const& name)
    {
        // POSIX doesn't have this capability
        return dynamic_library();
    }

    dynamic_library dynamic_library::find_by_symbol(std::string const& symbol)
    {
        dynamic_library library;
        LOG_DEBUG("Loading symbol.");

        // Load the "null" library; this will cause dlsym to search for the symbol
        void* handle = dlopen(nullptr, RTLD_GLOBAL | RTLD_LAZY);
        if (!handle) {
            return library;
        }

        // Check to see if a search for the symbol succeeds
        if (!dlsym(handle, symbol.c_str())) {
            dlclose(handle);
            return library;
        }

        // At least one loaded module will resolve the given symbol
        // Return this handle to allow the caller to search for other symbols
        library._handle = handle;
        library._first_load = false;
        return library;
    }

    bool dynamic_library::load(string const& name)
    {
        close();
        LOG_DEBUG("Loading library");

        // Don't actually perform a load to determine if it is already loaded
        _handle = dlopen(name.c_str(), RTLD_LAZY | RTLD_NOLOAD);
        if (!_handle) {
            // Load now
            _handle = dlopen(name.c_str(), RTLD_LAZY);
            if (!_handle) {
                LOG_DEBUG("Library %1% not found %2% (%3%).", name.c_str(), strerror(errno), errno);
                return false;
            }
            _first_load = true;
        }
        _name = name;
        return true;
    }

    void dynamic_library::close()
    {
        if (_handle) {
            dlclose(_handle);
            _handle = nullptr;
        }
        _name.clear();
        _first_load = false;
    }

    void* dynamic_library::find_symbol(string const& name, bool throw_if_missing, string const& alias) const
    {
        if (!_handle) {
            if (throw_if_missing) {
                throw missing_import_exception("library is not loaded.");
            } else {
                LOG_DEBUG("Library %1% is not loaded when attempting to load symbol %2%.", _name.c_str(), name.c_str());
            }
            return nullptr;
        }
        void* symbol = dlsym(_handle, name.c_str());
        if (!symbol && !alias.empty()) {
            LOG_DEBUG("Symbol %1% not found in library %2%, trying alias %3%.", name.c_str(), _name.c_str(), alias.c_str());
            symbol = dlsym(_handle, alias.c_str());
        }
        if (!symbol) {
            if (throw_if_missing) {
                throw missing_import_exception((boost::format("symbol %1% was not found in %2%.") % name %_name).str());
            } else {
                LOG_DEBUG("Symbol %1% not found in library %2%.", name.c_str(), _name.c_str());
            }
        }
        return symbol;
    }

}}  // namespace facter::util

