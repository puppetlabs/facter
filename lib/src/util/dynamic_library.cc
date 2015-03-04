#include <internal/util/dynamic_library.hpp>
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

}}  // namespace facter::util
