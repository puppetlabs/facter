#include <internal/util/scoped_file.hpp>
#include <boost/nowide/cstdio.hpp>

using namespace std;
using namespace leatherman::util;

namespace facter { namespace util {

    scoped_file::scoped_file(string const& path, string const& mode) :
       scoped_resource(boost::nowide::fopen(path.c_str(), mode.c_str()), close)
    {
    }

    scoped_file::scoped_file(FILE* file) :
       scoped_resource(move(file), close)
    {
    }

    void scoped_file::close(FILE* file)
    {
       if (file) {
           fclose(file);
       }
    }

}}  // namespace facter::util
