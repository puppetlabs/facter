#include <facter/util/file.hpp>
#include <sstream>
#include <boost/nowide/fstream.hpp>

using namespace std;

namespace facter { namespace util {

    bool file::each_line(string const& path, function<bool(string&)> callback)
    {
        boost::nowide::ifstream in(path.c_str());
        if (!in) {
            return false;
        }

        string line;
        while (getline(in, line)) {
            if (!callback(line)) {
                break;
            }
        }
        return true;
    }

    string file::read(string const& path)
    {
        string contents;
        if (!read(path, contents)) {
            return {};
        }
        return contents;
    }

    bool file::read(string const& path, string& contents)
    {
        boost::nowide::ifstream in(path.c_str(), ios::in | ios::binary);
        ostringstream buffer;
        if (!in) {
            return false;
        }
        buffer << in.rdbuf();
        contents = buffer.str();
        return true;
    }

}}  // namespace facter::util
