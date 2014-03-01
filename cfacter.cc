#include "cfacterlib.h"

#include <getopt.h>
#include <iostream>

using namespace std;
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
         ;
}

void version()
{
    cout << "0.0.1" << endl;
}

int main(int argc, char **argv)
{
    static struct option long_options[] = {
        {"help", no_argument, NULL, 'h'},
        {"json", no_argument, NULL, 'j'},
        {"version", no_argument, NULL, 'v'},
        {NULL, 0, NULL, 0}
    };

    // loop over all of the options
    int ch;
    while ((ch = getopt_long(argc, argv, "hjv", long_options, NULL)) != -1) {
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
            // do json, that's the only output option atm
            break;
        }
    }

    loadfacts();

#define MAX_LEN_FACTS_JSON_STRING (1024 * 1024)  // go crazy here
    char facts_json[MAX_LEN_FACTS_JSON_STRING];

    if (optind == argc) { // display all facts
        if (to_json(facts_json, MAX_LEN_FACTS_JSON_STRING) < 0) {
            cout << "Wow, that's a lot of facts" << endl;
            exit(1);
        }
        cout << facts_json << endl;
    } else {
        // display requested fact(s)
        while (optind < argc) {
            // fix me
            if (value(argv[optind], facts_json, MAX_LEN_FACTS_JSON_STRING) == 0)
                cout << facts_json << endl;
            ++optind;
        }
    }
}
