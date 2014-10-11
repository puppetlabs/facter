#include <facter/util/windows/string_conv.hpp>
#include <windows.h>

using namespace std;

namespace facter { namespace util { namespace windows {

    wstring to_utf16(string const& s)
    {
        auto numChars = MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, NULL, 0);
        wstring ws(numChars, '\0');
        numChars = MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, &ws[0], numChars);
        return ws;
    }

    string to_utf8(wstring const& ws)
    {
        auto numChars = WideCharToMultiByte(CP_UTF8, 0, ws.c_str(), -1, NULL, 0, NULL, NULL);
        string s(numChars, '\0');
        numChars = WideCharToMultiByte(CP_UTF8, 0, ws.c_str(), -1, &s[0], numChars, NULL, NULL);
        return s;
    }

}}}  // namespace facter::util::windows
