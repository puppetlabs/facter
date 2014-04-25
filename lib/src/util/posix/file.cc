#include <facter/util/file.hpp>
#include <sys/stat.h>
#include <sstream>
#include <fstream>

using namespace std;

namespace facter { namespace util {

    bool file::exists(string const& path)
    {
        struct stat buffer;
        if (stat(path.c_str(), &buffer) != 0) {
            return false;
        }

        return S_ISREG(buffer.st_mode);
    }

    // TODO: this is standard-compliant, so it should shared between POSIX and Windows
    string file::read(string const& path)
    {
        ifstream in(path, ios::in | ios::binary);
        ostringstream contents;
        if (in) {
            contents << in.rdbuf();
        }
        return contents.str();
    }

    // TODO: this is standard-compliant, so it can be shared between POSIX and Windows
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
