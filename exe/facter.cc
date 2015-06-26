#include <facter/version.h>
#include <facter/logging/logging.hpp>
#include <facter/facts/collection.hpp>
#include <facter/ruby/ruby.hpp>
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
using namespace facter::facts;
using namespace facter::logging;
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
            ("custom-dir", po::value<vector<string>>(&custom_directories), "A directory to use for custom facts.")
            ("debug,d", "Enable debug output.")
            ("external-dir", po::value<vector<string>>(&external_directories), "A directory to use for external facts.")
            ("help", "Print this help message.")
            ("json,j", "Output in JSON format.")
            ("show-legacy", "Show legacy facts when querying all facts.")
            ("log-level,l", po::value<level>()->default_value(level::warning, "warn"), "Set logging level.\nSupported levels are: none, trace, debug, info, warn, error, and fatal.")
            ("no-color", "Disables color output.")
            ("no-custom-facts", "Disables custom facts.")
            ("no-external-facts", "Disables external facts.")
            ("no-ruby", "Disables loading Ruby, facts requiring Ruby, and custom facts.")
            ("trace", "Enable backtraces for custom facts.")
            ("verbose", "Enable verbose (info) output.")
            ("version,v", "Print the version and exit.")
            ("yaml,y", "Output in YAML format.");

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
            if (vm.count("no-external-facts") && vm.count("external-dir")) {
                throw po::error("no-external-facts and external-dir options conflict: please specify only one.");
            }
            if (vm.count("no-custom-facts") && vm.count("custom-dir")) {
                throw po::error("no-custom-facts and custom-dir options conflict: please specify only one.");
            }
            if ((vm.count("debug") + vm.count("verbose") + (vm["log-level"].defaulted() ? 0 : 1)) > 1) {
                throw po::error("debug, verbose, and log-level options conflict: please specify only one.");
            }
            if (vm.count("no-ruby") && vm.count("custom-dir")) {
              throw po::error("no-ruby and custom-dir options conflict: please specify only one.");
            }
        }
        catch (exception& ex) {
            boost::nowide::cerr << colorize(level::error) << "error: " << ex.what() << colorize() << "\n" << endl;
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
        if (vm.count("debug")) {
            lvl = level::debug;
        } else if (vm.count("verbose")) {
            lvl = level::info;
        }
        set_level(lvl);

        log_command_line(argc, argv);

        // Initialize Ruby in main
        bool ruby = (vm.count("no-ruby") == 0) && facter::ruby::initialize(vm.count("trace") == 1);

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
        facts.add_default_facts(ruby);

        if (!vm.count("no-external-facts")) {
            facts.add_external_facts(external_directories);
        }

        // Add the environment facts
        facts.add_environment_facts();

        if (ruby && !vm.count("no-custom-facts")) {
            facter::ruby::load_custom_facts(facts, custom_directories);
        }

        // Output the facts
        format fmt = format::hash;
        if (vm.count("json")) {
            fmt = format::json;
        } else if (vm.count("yaml")) {
            fmt = format::yaml;
        }

        bool show_legacy = vm.count("show-legacy");
        facts.write(boost::nowide::cout, fmt, queries, show_legacy);
        boost::nowide::cout << endl;
    } catch (exception& ex) {
        log(level::fatal, "unhandled exception: %1%", ex.what());
    }

    return error_logged() ? EXIT_FAILURE : EXIT_SUCCESS;
}
