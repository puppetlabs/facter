#include <facter/util/file.hpp>
#include <sstream>
#include <fstream>

using namespace std;

namespace facter { namespace util {

    string file::read(string const& path)
    {
        ifstream in(path, ios::in | ios::binary);
        ostringstream contents;
        if (in) {
            contents << in.rdbuf();
        }
        return contents.str();
    }

    string file::read_first_line(string const& path)
    {
        ifstream in(path);
        string value;
        if (getline(in, value)) {
            return value;
        }
        return {};
    }

}}  // namespace facter::util
