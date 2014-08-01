#include <facter/facterlib.h>
#include <facter/facts/collection.hpp>
#include <facter/logging/logging.hpp>
#include <facter/ruby/api.hpp>
#include <facter/util/string.hpp>
#include <boost/program_options.hpp>

#include <iostream>
#include <set>
#include <algorithm>
#include <iterator>

using namespace std;
using namespace facter::util;
using namespace facter::facts;
using namespace facter::ruby;
namespace po = boost::program_options;

LOG_DECLARE_NAMESPACE("main");

void help(po::options_description& desc)
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
        "  cfacter [options] [fact] [fact] [...]\n"
        "\n"
        "Options\n"
        "=======\n\n" << desc <<
        "\nDescription\n"
        "===========\n"
        "\n"
        "Collect and display facts about the current system.  The library behind\n"
        "cfacter is easy to expand, making cfacter an easy way to collect information\n"
        "about a system.\n"
        "\n"
        "If no facts are specifically asked for, then all facts will be returned.\n"
        "\n"
        "Example\n"
        "=======\n\n"
        "  cfacter kernel\n";
}

void log_command_line(int argc, char** argv)
{
    if (!LOG_IS_INFO_ENABLED()) {
        return;
    }
    ostringstream command_line;
    for (int i = 1; i < argc; ++i) {
        if (command_line.tellp() != 0) {
            command_line << ' ';
        }
        command_line << argv[i];
    }
    LOG_INFO("executed with command line: %1%.", command_line.str());
}

void log_requested_facts(set<string> const& facts)
{
    if (!LOG_IS_INFO_ENABLED()) {
        return;
    }

    if (facts.empty()) {
        LOG_INFO("resolving all facts.");
        return;
    }

    ostringstream requested_facts;
    for (auto const& fact : facts) {
        if (fact.empty()) {
            continue;
        }
        if (requested_facts.tellp() != 0) {
            requested_facts << ' ';
        }
        requested_facts << fact;
    }
    LOG_INFO("resolving requested facts: %1%.", requested_facts.str());
}

int main(int argc, char **argv)
{
    try
    {
        vector<string> external_directories;
        vector<string> custom_directories;

        // Build a list of options visible on the command line
        // Keep this list sorted alphabetically
        po::options_description visible_options("");
        visible_options.add_options()
            ("custom-dir", po::value<vector<string>>(&custom_directories), "A directory to use for custom facts.")
            ("debug,d", "Enable debug output.")
            ("external-dir", po::value<vector<string>>(&external_directories), "A directory to use for external facts.")
            ("help", "Print this help message.")
            ("json,j", "Output in JSON format.")
            ("no-custom-facts", "Turn off custom facts")
            ("no-external-facts", "Turn off external facts")
            ("verbose", "Enable verbose (info) output.")
            ("version,v", "Print the version and exit.")
            ("yaml,y", "Output in YAML format.");

        // Build a list of "hidden" options that are not visible on the command line
        po::options_description hidden_options("");
        hidden_options.add_options()
            ("fact", po::value<vector<string>>());

        // Create the supported command line options (visible + hidden)
        po::options_description command_line_options;
        command_line_options.add(visible_options).add(hidden_options);

        // Build a list of positional options (in our case, just fact names)
        po::positional_options_description positional_options;
        positional_options.add("fact", -1);

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
            if (vm.count("json") && vm.count("yaml")) {
                throw po::error("json and yaml options conflict. please specify one or the other.");
            }
            if (vm.count("no-external-dir") && vm.count("external-dir")) {
                throw po::error("no-external-dir and external-dir options conflict. please specify one or the other.");
            }
        }
        catch(po::error& ex) {
            cerr << "error: " << ex.what() << "\n\n";
            help(visible_options);
            return EXIT_FAILURE;
        }

        // Check for printing the version
        if (vm.count("version")) {
            cout << get_facter_version() << endl;
            return EXIT_SUCCESS;
        }

        // Get the logging level
        facter::logging::log_level level = facter::logging::log_level::warning;
        if (vm.count("debug")) {
            level = facter::logging::log_level::debug;
        } else if (vm.count("verbose")) {
            level = facter::logging::log_level::info;
        }

        // Configure logging
        configure_logging(level);
        log_command_line(argc, argv);

        // Initialize Ruby in main
        // This needs to be done here to ensure the stack is at the appropriate depth for the Ruby VM
        api* ruby = nullptr;
        if (!vm.count("no-custom-facts")) {
            ruby = api::instance();
            if (ruby) {
                ruby->initialize();
            }
        }

        // Build a set of requested facts from the command line
        set<string> requested_facts;
        if (vm.count("fact")) {
            auto const& fact_parameters = vm["fact"].as<vector<string>>();

            // Convert the given strings into a set of unique lowercase fact names
            transform(
                fact_parameters.begin(),
                fact_parameters.end(),
                inserter(requested_facts, requested_facts.end()),
                [](string const& s) { return trim(to_lower(string(s))); });
        }

        log_requested_facts(requested_facts);

        collection facts;
        facts.add_default_facts();

        if (!vm.count("no-external-facts")) {
            facts.add_external_facts(external_directories);
        }

        if (ruby) {
            facts.add_custom_facts(*ruby, custom_directories);
        }

        // Filter to only the requested facts
        if (!requested_facts.empty()) {
            facts.filter(requested_facts);
        }

        // Output the facts
        format fmt = format::hash;
        if (vm.count("json")) {
            fmt = format::json;
        } else if (vm.count("yaml")) {
            fmt = format::yaml;
        }
        facts.write(cout, fmt);
        cout << '\n';
    } catch (exception& ex) {
        LOG_FATAL("unhandled exception: %1%", ex.what());
        return EXIT_FAILURE;
    }
}
