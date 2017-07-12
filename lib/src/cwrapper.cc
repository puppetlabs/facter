#include <facter/cwrapper.hpp>

#include <facter/facts/collection.hpp>
#include <facter/util/config.hpp>

#include <hocon/program_options.hpp>

// boost includes are not always warning-clean. Disable warnings that
// cause problems before including the headers, then re-enable the warnings.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wattributes"
#include <boost/program_options.hpp>
#pragma GCC diagnostic pop

#include "stdlib.h"
#include <sstream>

namespace po = boost::program_options;

uint8_t get_default_facts(char **result) {
    try {
        po::variables_map vm {};
        hocon::shared_config hocon_conf;
        hocon_conf = facter::util::config::load_default_config_file();

        facter::util::config::load_global_settings(hocon_conf, vm);
        facter::util::config::load_cli_settings(hocon_conf, vm);
        facter::util::config::load_fact_settings(hocon_conf, vm);

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
        *result = new char [json_facts.length()+1];
        std::strcpy(*result, json_facts.c_str());
    } catch (const std::exception& e) {
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
