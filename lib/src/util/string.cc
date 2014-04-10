#include <util/string.hpp>
#include <sstream>
#include <algorithm>
#include <iterator>

using namespace std;

namespace cfacter { namespace util {

    initializer_list<char> default_trim_set = { '\r', '\n', ' ', '\t', '\v', '\f' };

    bool starts_with(string const& str, string const& prefix)
    {
        return prefix.size() <= str.size() && equal(prefix.begin(), prefix.end(), str.begin());
    }

    bool ends_with(string const& str, string const& suffix)
    {
        return suffix.size() <= str.size() && equal(suffix.rbegin(), suffix.rend(), str.rbegin());
    }

    string& ltrim(string& str, initializer_list<char> const& set)
    {
        str.erase(str.begin(), find_if(str.begin(), str.end(), [&set](char c) {
            return find(set.begin(), set.end(), c) == set.end();
        }));
        return str;
    }

    string& ltrim(string&& str, initializer_list<char> const& set)
    {
        return ltrim(str, set);
    }

    string& rtrim(string& str, initializer_list<char> const& set)
    {
        str.erase(find_if(str.rbegin(), str.rend(), [&set](char c) {
            return find(set.begin(), set.end(), c) == set.end();
        }).base(), str.end());
        return str;
    }

    string& rtrim(string&& str, initializer_list<char> const& set)
    {
        return rtrim(str, set);
    }

    string& trim(std::string& str, initializer_list<char> const& set)
    {
        return ltrim(rtrim(str, set), set);
    }

    string& trim(string&& str, initializer_list<char> const& set)
    {
        return trim(str, set);
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
