#include <facter/util/scoped_resource.hpp>
#include <internal/util/windows/system_error.hpp>
#include <internal/util/windows/windows.hpp>
#include <boost/format.hpp>

using namespace std;

namespace facter { namespace util { namespace windows {

    string system_error(DWORD err)
    {
        LPWSTR _pBuffer = nullptr;
        FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL, err, 0, (LPWSTR) &_pBuffer, 0, NULL);

        // boost format could throw, so ensure the buffer is freed.
        scoped_resource<LPWSTR> pBuffer(move(_pBuffer), [](LPWSTR pbuf) { if (pbuf) LocalFree(pbuf); });

        return (boost::format("%ls (%s)") % pBuffer % err).str();
    }

    string system_error()
    {
        return system_error(GetLastError());
    }

}}}  // namespace facter::util::windows
