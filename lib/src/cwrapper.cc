#include <facter/cwrapper.hpp>

#include <facter/facts/collection.hpp>
#include <facter/util/config.hpp>

#include <stdlib.h>
#include <stdio.h>
#include <sstream>

uint8_t get_default_facts(char **result) {
    try {
        // NB: ssh resolver cannot be blocked
        facter::facts::collection facts {{},      // blocklist set
                                         {},      // ttls map (resolvers - ttl)
                                         true};   // ignore_cache flag

        // The boolean arg is meant to avoid including ruby facts
        facts.add_default_facts(false);

        // NB: skipping the add_environment_facts() call

        // TODO: consider iterating only the facts we're interested
        // in by using the 'queries' arg
        std::ostringstream stream;
        facts.write(stream,
                    facter::facts::format::json,
                    {},     // queries vector
                    true,   // show_legacy flag
                    true);  // strict_errors flag

        auto json_facts = stream.str();
        auto l = json_facts.length()+1;
        *result = new char [l];
        strncpy(*result, json_facts.c_str(), l);
    } catch (const std::exception&) {
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
