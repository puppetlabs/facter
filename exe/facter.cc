#include <facter/version.h>
#include <facter/logging/logging.hpp>
#include <facter/facts/collection.hpp>
#include <facter/ruby/ruby.hpp>
#include <facter/util/config.hpp>
#include <hocon/program_options.hpp>
#include <leatherman/util/environment.hpp>
#include <leatherman/util/scope_exit.hpp>
#include <boost/algorithm/string.hpp>
// Note the caveats in nowide::cout/cerr; they're not synchronized with stdio.
// Thus they can't be relied on to flush before program exit.
// Use endl/ends or flush to force synchronization when necessary.
#include <boost/nowide/iostream.hpp>
#include <boost/nowide/args.hpp>

// boost includes are not always warning-clean. Disable warnings that
// cause problems before including the headers, then re-enable the warnings.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wattributes"
#include <boost/program_options.hpp>
#pragma GCC diagnostic pop

#include <iostream>
#include <set>
#include <algorithm>
#include <iterator>

using namespace std;
using namespace hocon;
using namespace facter::facts;
using namespace facter::logging;
using leatherman::util::environment;
namespace po = boost::program_options;


void help(po::options_description& desc)
{
    boost::nowide::cout <<
        "Synopsis\n"
        "========\n"
        "\n"
        "Collect and display facts about the system.\n"
        "\n"
        "Usage\n"
        "=====\n"
        "\n"
        "  facter [options] [query] [query] [...]\n"
        "\n"
        "Options\n"
        "=======\n\n" << desc <<
        "\nDescription\n"
        "===========\n"
        "\n"
        "Collect and display facts about the current system.  The library behind\n"
        "facter is easy to extend, making facter an easy way to collect information\n"
        "about a system.\n"
        "\n"
        "If no queries are given, then all facts will be returned.\n"
        "\n"
        "Example Queries\n"
        "===============\n\n"
        "  facter kernel\n"
        "  facter networking.ip\n"
        "  facter processors.models.0" << endl;
}

void log_command_line(int argc, char** argv)
{
    if (!is_enabled(level::info)) {
        return;
    }
    ostringstream command_line;
    for (int i = 1; i < argc; ++i) {
        if (command_line.tellp() != static_cast<streampos>(0)) {
            command_line << ' ';
        }
        command_line << argv[i];
    }
    log(level::info, "executed with command line: %1%.", command_line.str());
}

void log_queries(set<string> const& queries)
{
    if (!is_enabled(level::info)) {
        return;
    }

    if (queries.empty()) {
        log(level::info, "resolving all facts.");
        return;
    }

    ostringstream output;
    for (auto const& query : queries) {
        if (query.empty()) {
            continue;
        }
        if (output.tellp() != static_cast<streampos>(0)) {
            output << ' ';
        }
        output << query;
    }
    log(level::info, "requested queries: %1%.", output.str());
}

int main(int argc, char **argv)
{
    try
    {
        // Fix args on Windows to be UTF-8
        boost::nowide::args arg_utf8(argc, argv);

        // Setup logging
        setup_logging(boost::nowide::cerr);

        vector<string> external_directories;
        vector<string> custom_directories;

        // Build a list of options visible on the command line
        // Keep this list sorted alphabetically
        po::options_description visible_options("");
        visible_options.add_options()
            ("color", "Enables color output.")
            ("config,c", po::value<string>(), "The location of the config file.")
            ("custom-dir", po::value<vector<string>>(), "A directory to use for custom facts.")
            ("debug,d", po::bool_switch()->default_value(false), "Enable debug output.")
            ("external-dir", po::value<vector<string>>(), "A directory to use for external facts.")
            ("help,h", "Print this help message.")
            ("json,j", "Output in JSON format.")
            ("show-legacy", "Show legacy facts when querying all facts.")
            ("log-level,l", po::value<level>()->default_value(level::warning, "warn"), "Set logging level.\nSupported levels are: none, trace, debug, info, warn, error, and fatal.")
            ("no-color", "Disables color output.")
            ("no-custom-facts", po::bool_switch()->default_value(false), "Disables custom facts.")
            ("no-external-facts", po::bool_switch()->default_value(false), "Disables external facts.")
            ("no-ruby", po::bool_switch()->default_value(false), "Disables loading Ruby, facts requiring Ruby, and custom facts.")
            ("puppet,p", "(Deprecated: use `puppet facts` instead) Load the Puppet libraries, thus allowing Facter to load Puppet-specific facts.")
            ("trace", po::bool_switch()->default_value(false), "Enable backtraces for custom facts.")
            ("verbose", po::bool_switch()->default_value(false), "Enable verbose (info) output.")
            ("version,v", "Print the version and exit.")
            ("yaml,y", "Output in YAML format.")
            ("strict", "Enables more aggressive error reporting.");

        // Build a list of "hidden" options that are not visible on the command line
        po::options_description hidden_options("");
        hidden_options.add_options()
            ("query", po::value<vector<string>>());

        // Create the supported command line options (visible + hidden)
        po::options_description command_line_options;
        command_line_options.add(visible_options).add(hidden_options);

        // Build a list of positional options (in our case, just queries)
        po::positional_options_description positional_options;
        positional_options.add("query", -1);

        po::variables_map vm;
        try {
            po::store(po::command_line_parser(argc, argv).
                      options(command_line_options).positional(positional_options).run(), vm);

            // Check for non-default config file location
            hocon::shared_config hocon_conf;
            if (vm.count("config")) {
                string conf_dir = vm["config"].as<string>();
                hocon_conf = facter::util::config::load_config_from(conf_dir);
            } else {
                hocon_conf = facter::util::config::load_default_config_file();
            }

            if (hocon_conf) {
                facter::util::config::load_global_settings(hocon_conf, vm);
                facter::util::config::load_cli_settings(hocon_conf, vm);
                facter::util::config::load_fact_settings(hocon_conf, vm);
            }

            // Check for a help option first before notifying
            if (vm.count("help")) {
                help(visible_options);
                return EXIT_SUCCESS;
            }

            po::notify(vm);

            // Check for conflicting options
            if (vm.count("color") && vm.count("no-color")) {
                throw po::error("color and no-color options conflict: please specify only one.");
            }
            if (vm.count("json") && vm.count("yaml")) {
                throw po::error("json and yaml options conflict: please specify only one.");
            }
            if (vm["no-external-facts"].as<bool>() && vm.count("external-dir")) {
                throw po::error("no-external-facts and external-dir options conflict: please specify only one.");
            }
            if (vm["no-custom-facts"].as<bool>() && vm.count("custom-dir")) {
                throw po::error("no-custom-facts and custom-dir options conflict: please specify only one.");
            }
            if ((vm["debug"].as<bool>() + vm["verbose"].as<bool>() + (vm["log-level"].defaulted() ? 0 : 1)) > 1) {
                throw po::error("debug, verbose, and log-level options conflict: please specify only one.");
            }
            if (vm["no-ruby"].as<bool>() && vm.count("custom-dir")) {
                throw po::error("no-ruby and custom-dir options conflict: please specify only one.");
            }
            if (vm.count("puppet") && vm["no-custom-facts"].as<bool>()) {
                throw po::error("puppet and no-custom-facts options conflict: please specify only one.");
            }
            if (vm.count("puppet") && vm["no-ruby"].as<bool>()) {
                throw po::error("puppet and no-ruby options conflict: please specify only one.");
            }
        }
        catch (exception& ex) {
            colorize(boost::nowide::cerr, level::error);
            boost::nowide::cerr << "error: " << ex.what() << "\n" << endl;
            colorize(boost::nowide::cerr);
            help(visible_options);
            return EXIT_FAILURE;
        }

        // Check for printing the version
        if (vm.count("version")) {
            boost::nowide::cout << LIBFACTER_VERSION_WITH_COMMIT << endl;
            return EXIT_SUCCESS;
        }

        // Set colorization; if no option was specified, use the default
        if (vm.count("color")) {
            set_colorization(true);
        } else if (vm.count("no-color")) {
            set_colorization(false);
        }

        // Get the logging level
        auto lvl= vm["log-level"].as<level>();
        if (vm["debug"].as<bool>()) {
            lvl = level::debug;
        } else if (vm["verbose"].as<bool>()) {
            lvl = level::info;
        }
        set_level(lvl);

        log_command_line(argc, argv);

        // Initialize Ruby in main
        bool ruby = (!vm["no-ruby"].as<bool>()) && facter::ruby::initialize(vm["trace"].as<bool>());
        leatherman::util::scope_exit ruby_cleanup{[ruby]() {
            if (ruby) {
                facter::ruby::uninitialize();
            }
        }};

        // Build a set of queries from the command line
        set<string> queries;
        if (vm.count("query")) {
            for (auto const &q : vm["query"].as<vector<string>>()) {
                // Strip whitespace and query delimiter
                string query = boost::trim_copy_if(q, boost::is_any_of(".") || boost::is_space());

                // Erase any duplicate consecutive delimiters
                query.erase(unique(query.begin(), query.end(), [](char a, char b) {
                    return a == b && a == '.';
                }), query.end());

                // Don't insert empty queries
                if (query.empty()) {
                    continue;
                }

                queries.emplace(move(query));
            }
        }

        log_queries(queries);

        collection facts;
        set<string> blocklist;
        if (vm.count("blocklist")) {
            auto facts_to_block = vm["blocklist"].as<vector<string>>();
            blocklist.insert(facts_to_block.begin(), facts_to_block.end());
        }
        facts.add_default_facts(ruby, blocklist);

        // Add the environment facts
        facts.add_environment_facts();

        if (ruby && !vm["no-custom-facts"].as<bool>()) {
            if (vm.count("custom-dir")) {
                custom_directories = vm["custom-dir"].as<vector<string>>();
            }
            facter::ruby::load_custom_facts(facts, vm.count("puppet"), custom_directories);
        }

        if (!vm["no-external-facts"].as<bool>()) {
          string inside_facter;
          environment::get("INSIDE_FACTER", inside_facter);

          if (inside_facter == "true") {
            log(level::debug, "Environment variable INSIDE_FACTER is set to 'true'");
            log(level::warning, "Facter was called recursively, skipping external facts. Add '--no-external-facts' to silence this warning");
          } else {
            environment::set("INSIDE_FACTER", "true");
            if (vm.count("external-dir")) {
                external_directories = vm["external-dir"].as<vector<string>>();
            }
            facts.add_external_facts(external_directories);
          }
        }

        // Output the facts
        format fmt = format::hash;
        if (vm.count("json")) {
            fmt = format::json;
        } else if (vm.count("yaml")) {
            fmt = format::yaml;
        }

        bool show_legacy = vm.count("show-legacy");
        bool strict_errors = vm.count("strict");
        facts.write(boost::nowide::cout, fmt, queries, show_legacy, strict_errors);
        boost::nowide::cout << endl;
    } catch (locale_error const& e) {
        boost::nowide::cerr << "failed to initialize logging system due to a locale error: " << e.what() << "\n" << endl;
        return 2;  // special error code to indicate we failed harder than normal
    } catch (exception& ex) {
        log(level::fatal, "unhandled exception: %1%", ex.what());
    }

    return error_logged() ? EXIT_FAILURE : EXIT_SUCCESS;
}
