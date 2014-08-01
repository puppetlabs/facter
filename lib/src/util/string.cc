#include <facter/util/string.hpp>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <iterator>
#include <boost/algorithm/string/predicate.hpp>

using namespace std;
using namespace boost::algorithm;

namespace facter { namespace util {

    initializer_list<char> default_trim_set = { '\r', '\n', ' ', '\t', '\v', '\f' };

    bool starts_with(string const& str, string const& prefix)
    {
        if (prefix.size() == 0) {
            return true;
        }
        return prefix.size() <= str.size() && equal(prefix.begin(), prefix.end(), str.begin());
    }

    bool ends_with(string const& str, string const& suffix)
    {
        if (suffix.size() == 0) {
            return true;
        }
        return suffix.size() <= str.size() && equal(suffix.rbegin(), suffix.rend(), str.rbegin());
    }

    string& ltrim(string& str, initializer_list<char> const& set)
    {
        str.erase(str.begin(), find_if(str.begin(), str.end(), [&set](char c) {
            return find(set.begin(), set.end(), c) == set.end();
        }));
        return str;
    }

    string&& ltrim(string&& str, initializer_list<char> const& set)
    {
        return move(ltrim(str, set));
    }

    string& rtrim(string& str, initializer_list<char> const& set)
    {
        str.erase(find_if(str.rbegin(), str.rend(), [&set](char c) {
            return find(set.begin(), set.end(), c) == set.end();
        }).base(), str.end());
        return str;
    }

    string&& rtrim(string&& str, initializer_list<char> const& set)
    {
        return move(rtrim(str, set));
    }

    string& trim(string& str, initializer_list<char> const& set)
    {
        return ltrim(rtrim(str, set), set);
    }

    string&& trim(string&& str, initializer_list<char> const& set)
    {
        return move(trim(str, set));
    }

    vector<string> tokenize(string const& str)
    {
        istringstream stream(str);
        return vector<string>(istream_iterator<string>(stream), istream_iterator<string>());
    }

    vector<string> split(string const& str, char delim, bool remove_empty)
    {
        vector<string> parts;
        istringstream stream(str);

        string part;
        while (getline(stream, part, delim)) {
            if (remove_empty && part.empty()) {
                continue;
            }
            parts.push_back(move(part));
        }
        // If the string ends in the delimiter (and isn't just the delimiter), add an empty string if not removing empty
        if (!remove_empty && str.size() > 1 && *str.rbegin() == delim) {
            parts.push_back("");
        }
        return parts;
    }

    string join(vector<string> const& strings, string const& delimiter)
    {
        ostringstream stream;

        bool first = true;
        for (auto const& str : strings) {
            if (first) {
                first = false;
            } else {
                stream << delimiter;
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

    string&& to_lower(string&& str)
    {
        return move(to_lower(str));
    }

    string& to_upper(string& str)
    {
        transform(str.begin(), str.end(), str.begin(), ::toupper);
        return str;
    }

    string&& to_upper(string&& str)
    {
        return move(to_upper(str));
    }

    string to_hex(uint8_t const* bytes, size_t length, bool uppercase)
    {
        ostringstream ss;
        if (bytes) {
            ss << hex << (uppercase ? std::uppercase : std::nouppercase) << setfill('0');
            for (size_t i = 0; i < length; ++i) {
                ss << setw(2) << static_cast<int>(bytes[i]);
            }
        }
        return ss.str();
    }

    void each_line(string const& s, function<bool(string&)> callback)
    {
        string line;
        istringstream in(s);
        while (getline(in, line)) {
            if (!callback(line)) {
                break;
            }
        }
    }

    int ci_char_traits::compare(char const* s1, char const* s2, size_t n)
    {
        return ilexicographical_compare(make_pair(s1, s1+n), make_pair(s2, s2+n));
    }

}}  // namespace facter::util
