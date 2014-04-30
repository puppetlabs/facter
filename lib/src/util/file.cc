#include <facter/util/file.hpp>
#include <sstream>
#include <fstream>

using namespace std;

namespace facter { namespace util { namespace file {

    string read(string const& path)
    {
        string contents;
        if (!read(path, contents)) {
            return {};
        }
        return contents;
    }

    bool read(string const& path, string& contents)
    {
        ifstream in(path, ios::in | ios::binary);
        ostringstream buffer;
        if (!in) {
            return false;
        }
        buffer << in.rdbuf();
        contents = buffer.str();
        return true;
    }

    string read_first_line(string const& path)
    {
        string line;
        if (!read_first_line(path, line)) {
            return {};
        }
        return line;
    }

    bool read_first_line(string const& path, string& line)
    {
        ifstream in(path);
        return static_cast<bool>(getline(in, line));
    }

}}}  // namespace facter::util::file
