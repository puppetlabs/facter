#include <facter/facts/windows/kernel_resolver.hpp>
#include <facter/facts/os.hpp>
#include <facter/util/windows/system_error.hpp>
#include <facter/util/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/optional.hpp>
#include <boost/algorithm/string/trim.hpp>
#include <boost/format.hpp>
#include <boost/nowide/convert.hpp>

using namespace std;
using namespace facter::util::windows;

namespace facter { namespace facts { namespace windows {

    static boost::optional<string> get_release()
    {
        // GetVersionEx requires the manifest is correct, and is essentially deprecated.
        // Another method of getting the OS version can be found at
        // http://msdn.microsoft.com/en-us/library/windows/desktop/ms724429(v=vs.85).aspx
        // and is what we use here.
        auto fileName = L"Kernel32.dll";
        auto fileVerSize = GetFileVersionInfoSizeW(fileName, nullptr);
        if (fileVerSize == 0) {
            return boost::none;
        }

        vector<wchar_t> buffer(fileVerSize);
        if (!GetFileVersionInfoW(fileName, 0, fileVerSize, buffer.data())) {
            return boost::none;
        }

        struct LANGANDCODEPAGE {
            WORD wLanguage, wCodePage;
        } *lpTranslate;
        UINT cbTranslate;

        if (!VerQueryValueW(buffer.data(), L"\\VarFileinfo\\Translation",
            reinterpret_cast<LPVOID*>(&lpTranslate), &cbTranslate)) {
            return boost::none;
        }

        // Use the 1st language found, as ProductVersion should be language-independent.
        wstring subBlock = str(boost::wformat(L"\\StringFileInfo\\%04x%04x\\ProductVersion")
            % lpTranslate->wLanguage % lpTranslate->wCodePage);

        wchar_t *version;
        UINT versionLen;
        if (!VerQueryValueW(buffer.data(), subBlock.c_str(), reinterpret_cast<LPVOID*>(&version), &versionLen)) {
            return boost::none;
        }

        // Strip the last (file version) token to get just the OS version.
        wstring versionStrW(version, versionLen);
        auto versionStr = boost::nowide::narrow(versionStrW);
        boost::trim_right_if(versionStr, [](char c) { return c != '.'; });  // Remove everything after '.'
        boost::trim_right_if(versionStr, [](char c) { return c == '.'; });  // Remove '.'

        return versionStr;
    }

    kernel_resolver::data kernel_resolver::collect_data(collection& facts)
    {
        data result;

        auto release = get_release();
        if (release) {
            result.release = move(*release);
            result.version = result.release;
        } else {
            LOG_DEBUG("failed to retrieve kernel facts: %1%", system_error());
        }

        result.name = os::windows;
        return result;
    }

}}}  // namespace facter::facts::windows
