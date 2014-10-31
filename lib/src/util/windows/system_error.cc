#include <facter/util/scoped_resource.hpp>
#include <facter/util/windows/string_conv.hpp>
#include <facter/util/windows/system_error.hpp>
#include <facter/util/windows/windows.hpp>
#include <boost/format.hpp>

using namespace std;

namespace facter { namespace util { namespace windows {

    string system_error(DWORD err)
    {
        LPWSTR _pBuffer = nullptr;
        FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL, err, 0, (LPWSTR) &_pBuffer, 0, NULL);

        // to_utf8 can throw, so ensure the buffer is freed.
        scoped_resource<LPWSTR> pBuffer(move(_pBuffer), [](LPWSTR pbuf) { if (pbuf) LocalFree(pbuf); });

        return (boost::format("%1% (%2%)") % to_utf8(wstring(pBuffer)) % err).str();
    }

    string system_error()
    {
        return system_error(GetLastError());
    }

}}}  // namespace facter::util::windows
