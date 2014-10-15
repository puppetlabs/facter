#include <facter/util/windows/string_conv.hpp>
#include <facter/util/windows/scoped_error.hpp>
#include <boost/format.hpp>
#include <windows.h>

using namespace std;

namespace facter { namespace util { namespace windows {

    string_conv_exception::string_conv_exception(string const& message) :
        runtime_error(message)
    {
    }

    wstring to_utf16(string const& s)
    {
        auto numChars = MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, NULL, 0);
        if (numChars > 0) {
            wstring ws(numChars, '\0');
            if (MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, &ws[0], numChars) > 0) {
                // MultiByteToWideChar required allocating space for the \0 char; resize to account for it.
                ws.resize(numChars-1);
                return ws;
            }
        }

        auto err = GetLastError();
        throw string_conv_exception(str(boost::format
            ("translation to utf16 of \"%1%\" failed: %2% (%3%)") % s % scoped_error(err) % err));
    }

    string to_utf8(wstring const& ws)
    {
        auto numChars = WideCharToMultiByte(CP_UTF8, 0, ws.c_str(), -1, NULL, 0, NULL, NULL);
        if (numChars > 0) {
            string s(numChars, '\0');
            if (WideCharToMultiByte(CP_UTF8, 0, ws.c_str(), -1, &s[0], numChars, NULL, NULL) > 0) {
                // WideCharToMultiByte required allocating space for the \0 char; resize to account for it.
                s.resize(numChars-1);
                return s;
            }
        }

        auto err = GetLastError();
        // Do a raw byte copy from ws to string for exception/logging, as we don't have wide-string versions.
        string raw_ws(ws.begin(), ws.end());
        throw string_conv_exception(str(boost::format
            ("translation to utf8 of \"%1%\" failed: %2% (%3%)") % raw_ws % scoped_error(err) % err));
    }

}}}  // namespace facter::util::windows
