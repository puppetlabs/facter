#include <iostream>
#include <facter/facterlib.h>
#include <facter/facts/fact_map.hpp>
#include <facter/logging/logging.hpp>
#include <facter/util/string.hpp>
#include <log4cxx/logger.h>
#include <log4cxx/propertyconfigurator.h>
#include <log4cxx/patternlayout.h>
#include <log4cxx/consoleappender.h>
#include <boost/program_options.hpp>
#include <boost/filesystem.hpp>
#include <iostream>
#include <set>
#include <algorithm>
#include <iterator>

using namespace std;
using namespace log4cxx;
using namespace facter::util;
using namespace facter::facts;
using namespace boost::filesystem;
namespace po = boost::program_options;
namespace bs = boost::system;

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

void configure_logger(LevelPtr level, string const& properties_file)
{
    bs::error_code ec;
    if (!properties_file.empty() && is_regular_file(properties_file, ec)) {
        PropertyConfigurator::configure(properties_file);
        return;
    }

    // If no configuration file given, use default settings
    LayoutPtr layout = new PatternLayout("%d %-5p %c - %m%n");
    AppenderPtr appender = new ConsoleAppender(layout);
    Logger::getRootLogger()->addAppender(appender);
    Logger::getRootLogger()->setLevel(level);
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
    LOG_INFO("Executed with command line: %1%.", command_line.str());
}

void log_requested_facts(set<string> const& facts)
{
    if (!LOG_IS_INFO_ENABLED()) {
        return;
    }

    if (facts.empty()) {
        LOG_INFO("Resolving all facts.");
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
    LOG_INFO("Resolving requested facts: %1%.", requested_facts.str());
}

int main(int argc, char **argv)
{
    try
    {
        string properties_file;

        // Build a list of options visible on the command line
        // Keep this list sorted alphabetically
        po::options_description visible_options("");
        visible_options.add_options()
            ("debug,d", "Enable debug output.")
            ("help", "Print this help message.")
            ("json,j", "Output in JSON format.")
            ("propfile,p", po::value<string>(&properties_file), "Configure logging with a log4cxx properties file.")
            ("verbose", "Enable verbose (info) output.")
            ("version,v", "Print the version and exit.");

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
        LevelPtr log_level = Level::getWarn();
        if (vm.count("debug")) {
            log_level = Level::getDebug();
        } else if (vm.count("verbose")) {
            log_level = Level::getInfo();
        }

        // Configure the logger
        configure_logger(log_level, properties_file);
        log_command_line(argc, argv);

        set<string> requested_facts;
        if (vm.count("fact")) {
            auto const& fact_parameters = vm["fact"].as<vector<string>>();

            // Convert the given strings into a set of unique lowercase fact names
            transform(
                fact_parameters.begin(),
                fact_parameters.end(),
                inserter(requested_facts, requested_facts.end()),
                [](string const& s) {
                    auto s2 = s;
                    trim(to_lower(s2));
                    return s2;
                });
        }

        log_requested_facts(requested_facts);

        // Resolve the facts and output the result
        fact_map facts;
        facts.resolve(requested_facts);

        // Output the facts
        if (vm.count("json")) {
            facts.write_json(cout);
        } else {
            cout << facts;
        }
        cout << '\n';
    } catch (exception& ex) {
        LOG_FATAL("Unhandled exception: %1%.", ex.what());
        return EXIT_FAILURE;
    }
}
