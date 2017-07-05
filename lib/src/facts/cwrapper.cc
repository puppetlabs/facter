#include <facter/facts/cwrapper.hpp>

#include <string>
#include "stdlib.h"

uint8_t get_facts(char **result) {
    std::string s {
        "{\n"
        "  \"timezone\": \"BST\",\n"
        "  \"uptime\": \"13 days\",\n"
        "  \"uptime_days\": 13,\n"
        "  \"uptime_hours\": 313,\n"
        "  \"uptime_seconds\": 1129594\n"
        "}"
    };

    *result = new char [s.length()+1];
    std::strcpy(*result, s.c_str());

    return EXIT_SUCCESS;
}
