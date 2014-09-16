#include <facter/util/windows/scoped_error.hpp>

using namespace std;

namespace facter { namespace util {

    scoped_error::scoped_error(DWORD err) : scoped_resource(nullptr, LocalFree), _err(err)
    {
        FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL, _err, 0, (LPTSTR) &_resource, 0, NULL);
    }

    scoped_error::scoped_error() : scoped_error(GetLastError()) {}

}}  // namespace facter::util
