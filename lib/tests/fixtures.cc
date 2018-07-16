#include "fixtures.hpp"
#include <boost/filesystem.hpp>
#include <boost/nowide/fstream.hpp>
#include <iostream>
#include <sstream>

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstrict-aliasing"
#pragma GCC diagnostic ignored "-Wunused-variable"
#include <boost/thread/thread.hpp>
#include <boost/chrono/duration.hpp>
#pragma GCC diagnostic pop

using namespace std;
using namespace boost::filesystem;

namespace facter { namespace testing {

    bool load_fixture(string const& name, string& data)
    {
        string path = string(LIBFACTER_TESTS_DIRECTORY) + "/fixtures/" + name;
        boost::nowide::ifstream in(path.c_str(), ios_base::in | ios_base::binary);
        if (!in) {
            return false;
        }
        ostringstream buffer;
        buffer << in.rdbuf();
        data = buffer.str();
        return true;
    }

    test_with_relative_path::test_with_relative_path(string const& dirname, string const& filename, string const& contents)
    {
        path dir(dirname);
        if (exists(dir)) {
            throw runtime_error(dir.string() + " already exists");
        }
        if (!create_directory(dir)) {
            throw runtime_error(dir.string() + " could not be created");
        }
        _dir = dir.string();

        path exec = dir / filename;
        {
            boost::nowide::ofstream exec_file(exec.string().c_str());
            exec_file << contents << endl;
        }
        permissions(exec, add_perms | owner_exe | group_exe);
    }

    test_with_relative_path::~test_with_relative_path()
    {
        if (!_dir.empty()) {
            remove_all(_dir);
            // Wait for at most 5 seconds to ensure the directory is destroyed.
            int count = 50;
            while (exists(_dir) && --count > 0) {
                boost::this_thread::sleep_for(boost::chrono::milliseconds(100));
            }
        }
    }

}}  // namespace facter::testing
