#include <util/string.hpp>
#include <cctype>
#include <sstream>
#include <algorithm>
#include <iterator>

using namespace std;

namespace cfacter { namespace util {

    string& ltrim(string& str)
    {
        str.erase(str.begin(), find_if(str.begin(), str.end(), [](char c) { return !isspace(c); }));
        return str;
    }

    string& ltrim(string&& str)
    {
        return ltrim(str);
    }

    string& rtrim(string& str)
    {
        str.erase(find_if(str.rbegin(), str.rend(), [](char c) { return !isspace(c); }).base(), str.end());
        return str;
    }

    string& rtrim(string&& str)
    {
        return rtrim(str);
    }

    string& trim(std::string& str)
    {
        return ltrim(rtrim(str));
    }

    string& trim(string&& str)
    {
        return trim(str);
    }

    vector<string> tokenize(string const& str)
    {
        istringstream stream(str);
        return vector<string>(istream_iterator<string>(stream), istream_iterator<string>());
    }

    vector<string> split(string const& str, char delim)
    {
        vector<string> parts;
        istringstream stream(str);

        string part;
        while (getline(stream, part, delim)) {
            if (part.empty()) {
                continue;
            }
            parts.push_back(std::move(part));
        }
        return parts;
    }

    string join(vector<string> const& strings, string const& delimiter)
    {
        ostringstream stream;

        bool first = true;
        for (auto const& str : strings) {
            if (!first) {
                stream << delimiter;
            } else {
                first = false;
            }
            stream << str;
        }
        return stream.str();
    }

    string& to_lower(string& str)
    {
        transform(str.begin(), str.end(), str.begin(), ::tolower);
        return str;
    }

    string& to_lower(string&& str)
    {
        return to_lower(str);
    }

    string& to_upper(string& str)
    {
        transform(str.begin(), str.end(), str.begin(), ::toupper);
        return str;
    }

    string& to_upper(string&& str)
    {
        return to_upper(str);
    }

    int ci_char_traits::compare(char const* s1, char const* s2, size_t n)
    {
        return strncasecmp(s1, s2, n);
    }

}}  // namespace cfacter::util
