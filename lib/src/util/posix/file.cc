#include <util/file.hpp>
#include <sys/stat.h>
#include <sstream>
#include <fstream>

using namespace std;

namespace cfacter { namespace util {

    bool file::exists(string const& path)
    {
        struct stat buffer;
        return stat(path.c_str(), &buffer) == 0;
    }

    // TODO: this is standard-compliant, so it can be shared between POSIX and Windows
    string file::read(string const& path)
    {
        ifstream in(path, std::ios::in | std::ios::binary);
        ostringstream contents;
        if (in)
        {
            contents << in.rdbuf();
        }
        return contents.str();
    }

}}  // namespace cfacter::util
