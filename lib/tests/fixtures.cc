#include "fixtures.hpp"
#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;

namespace facter { namespace testing {

    bool load_fixture(string const& name, string& data)
    {
        string path = string(LIBFACTER_TESTS_DIRECTORY) + "/fixtures/" + name;
        ifstream in(path, ios_base::in | ios_base::binary);
        if (!in) {
            return false;
        }
        ostringstream buffer;
        buffer << in.rdbuf();
        data = buffer.str();
        return true;
    }

}}  // namespace facter::testing
