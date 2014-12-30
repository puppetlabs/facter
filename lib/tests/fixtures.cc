#include "fixtures.hpp"
#include <iostream>
#include <boost/nowide/fstream.hpp>
#include <sstream>
#include <gmock/gmock.h>
#include <boost/filesystem.hpp>

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

    test_with_relative_path::test_with_relative_path(string filename, string contents)
    {
        path dir(::testing::UnitTest::GetInstance()->current_test_info()->name());
        if (exists(dir)) {
            throw runtime_error(dir.string()+" already exists");
        }
        if (!create_directory(dir)) {
            throw runtime_error(dir.string()+" could not be created");
        }
        _dir = dir.string();

        path exec = dir / filename;
        {
            boost::nowide::ofstream exec_file(exec.string().c_str());
            exec_file << contents << endl;
        }
        permissions(exec, add_perms | owner_exe | group_exe);
        _file = exec.string();
    }

    test_with_relative_path::~test_with_relative_path()
    {
        if (!_dir.empty()) {
            remove_all(_dir);
        }
    }

}}  // namespace facter::testing
