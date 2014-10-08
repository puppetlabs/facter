#include <facter/facts/windows/operating_system_resolver.hpp>
#include <facter/facts/os.hpp>
#include <facter/util/windows/scoped_error.hpp>
#include <facter/logging/logging.hpp>
#include <boost/optional.hpp>
#include <boost/algorithm/string/trim.hpp>
#include <windows.h>
#include <strsafe.h>

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.windows.operating_system"

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace windows {

    static boost::optional<string> get_release()
    {
        // GetVersionEx requires the manifest is correct, and is essentially deprecated.
        // Another method of getting the OS version can be found at
        // http://msdn.microsoft.com/en-us/library/windows/desktop/ms724429(v=vs.85).aspx
        // and is what we use here.
        auto fileName = "Kernel32.dll";
        auto fileVerSize = GetFileVersionInfoSize(fileName, nullptr);
        if (fileVerSize == 0) {
            return boost::none;
        }

        vector<char> buffer(fileVerSize);
        if (!GetFileVersionInfo(fileName, 0, fileVerSize, buffer.data())) {
            return boost::none;
        }

        struct LANGANDCODEPAGE {
            WORD wLanguage, wCodePage;
        } *lpTranslate;
        UINT cbTranslate;

        if (!VerQueryValue(buffer.data(), TEXT("\\VarFileinfo\\Translation"),
            reinterpret_cast<LPVOID*>(&lpTranslate), &cbTranslate)) {
            return boost::none;
        }

        // Use the 1st language found, as ProductVersion should be language-independent.
        TCHAR subBlock[50];
        if (FAILED(StringCchPrintf(subBlock, 50, TEXT("\\StringFileInfo\\%04x%04x\\ProductVersion"),
            lpTranslate->wLanguage, lpTranslate->wCodePage))) {
            return boost::none;
        }

        char *version;
        UINT versionLen;
        if (!VerQueryValue(buffer.data(), subBlock, reinterpret_cast<LPVOID*>(&version), &versionLen)) {
            return boost::none;
        }

        // Strip the last (file version) token to get just the OS version.
        string versionStr(version, versionLen);
        boost::trim_right_if(versionStr, [](char c) { return c != '.'; });  // Remove everything after '.'
        boost::trim_right_if(versionStr, [](char c) { return c == '.'; });  // Remove '.'

        return versionStr;
    }

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        data result = resolvers::operating_system_resolver::collect_data(facts);

        auto release = get_release();
        if (release) {
            result.release = move(*release);
        } else {
            auto err = GetLastError();
            LOG_DEBUG("failed to retrieve os version info: %1% (%2%)", scoped_error(err), err);
        }

        result.name = os::windows;
        return result;
    }

}}}  // namespace facter::facts::windows
