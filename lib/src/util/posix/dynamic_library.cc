#include <facter/util/dynamic_library.hpp>
#include <dlfcn.h>
#include <boost/format.hpp>

using namespace std;

namespace facter { namespace util {

    missing_import_exception::missing_import_exception(string const& message) :
        runtime_error(message)
    {
    }

    dynamic_library::dynamic_library() :
        _handle(nullptr),
        _first_load(false)
    {
    }

    dynamic_library::~dynamic_library()
    {
        close();
    }

    dynamic_library::dynamic_library(dynamic_library&& other) :
        _handle(nullptr),
        _first_load(false)
    {
        *this = move(other);
    }

    dynamic_library& dynamic_library::operator=(dynamic_library&& other)
    {
        close();
        _handle = other._handle;
        _name = other._name;
        _first_load = other._first_load;
        other._handle = nullptr;
        other._name.clear();
        other._first_load = false;
        return *this;
    }

    dynamic_library dynamic_library::find_by_name(std::string const& name)
    {
        // POSIX doesn't have this capability
        return dynamic_library();
    }

    dynamic_library dynamic_library::find_by_symbol(std::string const& symbol)
    {
        dynamic_library library;

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

        // Don't actually perform a load to determine if it is already loaded
        _handle = dlopen(name.c_str(), RTLD_LAZY | RTLD_NOLOAD);
        if (!_handle) {
            // Load now
            _handle = dlopen(name.c_str(), RTLD_LAZY);
            if (!_handle) {
                return false;
            }
            _first_load = true;
        }
        _name = name;
        return true;
    }

    bool dynamic_library::loaded() const
    {
        return _handle != nullptr;
    }

    bool dynamic_library::first_load() const
    {
        return _first_load;
    }

    string const& dynamic_library::name() const
    {
        return _name;
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
            }
            return nullptr;
        }
        void* symbol = dlsym(_handle, name.c_str());
        if (!symbol && !alias.empty()) {
            symbol = dlsym(_handle, alias.c_str());
        }
        if (throw_if_missing && !symbol) {
            throw missing_import_exception((boost::format("symbol %1% was not found in %2%.") % name %_name).str());
        }
        return symbol;
    }

}}  // namespace facter::util
