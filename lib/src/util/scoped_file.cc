#include <facter/util/scoped_file.hpp>

using namespace std;

namespace facter { namespace util {

    scoped_file::scoped_file(string const& path, string const& mode) :
       scoped_resource(fopen(path.c_str(), mode.c_str()), close)
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
