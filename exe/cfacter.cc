#include <cfacterlib.h>
#include "../version.h"
#include <getopt.h>
#include <iostream>
#include <facts/fact_map.hpp>

using namespace std;
using namespace cfacter::facts;

void help()
{
    cout <<
              "Synopsis\n"
              "========\n"
              "\n"
              "Collect and display facts about the system.\n"
              "\n"
              "Usage\n"
              "=====\n"
              "\n"
              "  cfacter [-h|--help] [-v|--version] [-j|--json] [fact] [fact] [...]\n"
              "\n"
              "Description\n"
              "===========\n"
              "\n"
              "Collect and display facts about the current system.  The library behind\n"
              "Facter is easy to expand, making Facter an easy way to collect information\n"
              "about a system.\n"
              "\n"
              "If no facts are specifically asked for, then all facts will be returned.\n"
              "\n"
              "EXAMPLE\n"
              "=======\n"
              "  cfacter kernel\n"
              "\n"
              "USAGE\n"
              "=====\n"
              "    -j, --json                       Emit facts in JSON format.\n"
              "    -v, --version                    Print the version and exit.\n"
              "    -h, --help                       Print this help message and exit.\n"
              "";
}

void version()
{
    cout << CFACTER_VERSION << endl;
}

int main(int argc, char **argv)
{
    // TODO: use Boost.Program_options?
    static struct option long_options[] = {
        {"help", no_argument, nullptr, 'h'},
        {"json", no_argument, nullptr, 'j'},
        {"version", no_argument, nullptr, 'v'},
        {nullptr, 0, nullptr, 0}
    };

    // loop over all of the options
    int ch;
    while ((ch = getopt_long(argc, argv, "hjv", long_options, nullptr)) != -1) {
        // check to see if a single character or long option came through
        switch (ch) {
        // short option 'v'
        case 'v':
            version();
            exit(0);

        // short option 'h'
        case 'h':
            help();
            exit(0);

        // short option 'j'
        case 'j':
            // TODO: properly support this
            break;
        }
    }

    // TODO: re-implement JSON output
    fact_map::instance().each([](string const& name, value const* val) {
        cout << name << " => " << (!val ? "<null>" : val->to_string()) << "\n";
        return false;
    });
}
