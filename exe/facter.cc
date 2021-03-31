#include <facter/version.h>
#include <facter/logging/logging.hpp>
#include <facter/facts/collection.hpp>
#include <facter/ruby/ruby.hpp>
#include <facter/util/cli.hpp>
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
using namespace facter::util::config;
using namespace facter::util::cli;
using leatherman::util::environment;
namespace po = boost::program_options;

// Mark string for translation (alias for facter::logging::format)
using facter::logging::_;

void help(po::options_description& desc)
{
    boost::nowide::cout <<
        _("Synopsis\n"
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
          "=======\n\n"
          "%1%\nDescription\n"
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
          "  facter processors.models.0"
          "\n"
          "\n"
          "Config File\n"
          "===========\n"
          "\n"
          "Contains settings for configuring external and custom fact directories,\n"
          "setting command line options, and blocking and caching facts.\n"
          "Loaded by default from %2%.\n"
          "See man page, README, or docs for more details.",
          desc, default_config_location()) << endl;
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

void print_fact_groups(map<string, vector<string>> const& fact_groups) {
    for (auto& group : fact_groups) {
        boost::nowide::cout << group.first << endl;
        for (auto& fact : group.second) {
            boost::nowide::cout << "  - " << fact << endl;
        }
    }
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
        unordered_map<string, int64_t> ttls;


        po::variables_map vm;
        po::options_description visible_options = get_visible_options();
        try {
            load_cli_options(vm, visible_options, argc, argv);

            // Check for non-default config file location
            hocon::shared_config hocon_conf;
            if (vm.count("config")) {
                string conf_dir = vm["config"].as<string>();
                hocon_conf = load_config_from(conf_dir);
            } else {
                hocon_conf = load_default_config_file();
            }

            if (hocon_conf) {
                load_global_settings(hocon_conf, vm);
                load_cli_settings(hocon_conf, vm);
                load_fact_settings(hocon_conf, vm);
                load_fact_groups_settings(hocon_conf, vm);
                ttls = load_ttls(hocon_conf);
            }

            // Check for a help option first before notifying
            if (vm.count("help")) {
                help(visible_options);
                return EXIT_SUCCESS;
            }

            po::notify(vm);

            validate_cli_options(vm);
        }
        catch (exception& ex) {
            colorize(boost::nowide::cerr, level::error);
            boost::nowide::cerr << _("error: %1%", ex.what()) << endl;
            colorize(boost::nowide::cerr);
            help(visible_options);
            return EXIT_FAILURE;
        }

        // Check for listing fact groups
        if (vm.count("list-cache-groups")) {
            collection facts;
            facts.add_default_facts(!vm.count("no-ruby"));
            print_fact_groups(facts.get_fact_groups());

            if (!vm["no-external-facts"].as<bool>()) {
                vector<string> external_directories;
                if (vm.count("external-dir")) {
                    external_directories = vm["external-dir"].as<vector<string>>();
                }
                print_fact_groups(facts.get_external_facts_groups(external_directories));
            }
            return EXIT_SUCCESS;
        }

        // Check for printing the version
        if (vm.count("version")) {
            boost::nowide::cout << LIBFACTER_VERSION_WITH_COMMIT << endl;
            return EXIT_SUCCESS;
        }

        if (vm.count("list-block-groups")) {
            collection facts;
            facts.add_default_facts(!vm.count("no-ruby"));
            print_fact_groups(facts.get_blockable_fact_groups());
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

        set<string> blocklist;
        if (vm.count("blocklist") && !vm.count("no-block")) {
            auto facts_to_block = vm["blocklist"].as<vector<string>>();
            blocklist.insert(facts_to_block.begin(), facts_to_block.end());
        }
        bool ignore_cache = vm.count("no-cache");
        bool sanitize_fact_name = false;
        if (vm.count("sanitize-fact-name")) {
            sanitize_fact_name = vm["sanitize-fact-name"].as<bool>();
        }
        collection facts(blocklist, ttls, ignore_cache, sanitize_fact_name);
        facts.add_default_facts(ruby);

        if (ruby && !vm["no-custom-facts"].as<bool>()) {
            if (vm.count("custom-dir")) {
                custom_directories = vm["custom-dir"].as<vector<string>>();
            }
            bool redirect_ruby_stdout = vm.count("json") || vm.count("yaml");
            facter::ruby::load_custom_facts(facts, vm.count("puppet"), redirect_ruby_stdout, custom_directories);
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

        // Add the environment facts
        facts.add_environment_facts();

        // Output the facts
        facter::facts::format fmt = facter::facts::format::hash;
        if (vm.count("json")) {
            fmt = facter::facts::format::json;
        } else if (vm.count("yaml")) {
            fmt = facter::facts::format::yaml;
        }

        bool show_legacy = vm.count("show-legacy");
        bool strict_errors = vm.count("strict");
        facts.write(boost::nowide::cout, fmt, queries, show_legacy, strict_errors);
        boost::nowide::cout << endl;
    } catch (locale_error const& e) {
        boost::nowide::cerr << _("failed to initialize logging system due to a locale error: %1%", e.what()) << endl;
        return 2;  // special error code to indicate we failed harder than normal
    } catch (exception& ex) {
        log(level::fatal, "unhandled exception: %1%", ex.what());
    }

    return error_logged() ? EXIT_FAILURE : EXIT_SUCCESS;
}
