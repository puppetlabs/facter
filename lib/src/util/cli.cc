#include <facter/util/cli.hpp>
#include <facter/util/config.hpp>
#include <boost/algorithm/string.hpp>
#include <hocon/program_options.hpp>
#include <leatherman/file_util/file.hpp>
#include <facter/logging/logging.hpp>

using namespace std;
using namespace facter::logging;
using namespace facter::util::config;
namespace po = boost::program_options;

// Mark string for translation (alias for facter::logging::format)
using facter::logging::_;

namespace facter { namespace util { namespace cli {

    void validate_cli_options(po::variables_map vm)
    {
        // Check for conflicting options
        if (vm.count("color") && vm.count("no-color")) {
            throw po::error(_("color and no-color options conflict: please specify only one."));
        }
        if (vm.count("json") && vm.count("yaml")) {
            throw po::error(_("json and yaml options conflict: please specify only one."));
        }
        if (vm["no-external-facts"].as<bool>() && vm.count("external-dir")) {
            throw po::error(_("no-external-facts and external-dir options conflict: please specify only one."));
        }
        if (vm["no-custom-facts"].as<bool>() && vm.count("custom-dir")) {
            throw po::error(_("no-custom-facts and custom-dir options conflict: please specify only one."));
        }
        if ((vm["debug"].as<bool>() + vm["verbose"].as<bool>() + (vm["log-level"].defaulted() ? 0 : 1)) > 1) {
            throw po::error(_("debug, verbose, and log-level options conflict: please specify only one."));
        }
        if (vm["no-ruby"].as<bool>() && vm.count("custom-dir")) {
            throw po::error(_("no-ruby and custom-dir options conflict: please specify only one."));
        }
        if (vm.count("puppet") && vm["no-custom-facts"].as<bool>()) {
            throw po::error(_("puppet and no-custom-facts options conflict: please specify only one."));
        }
        if (vm.count("puppet") && vm["no-ruby"].as<bool>()) {
            throw po::error(_("puppet and no-ruby options conflict: please specify only one."));
        }
    }

    po::options_description get_visible_options()
    {
        // Build a list of options visible on the command line
        // Keep this list sorted alphabetically
        // Many of these options also can be specified in the config file,
        // see facter::util::config. Because of differences between the way
        // options are specified in the config file and on the command line,
        // these options need to be specified separately (e.g. on the command
        // line, flag presence indicates `true`, while in the config file, the
        // boolean must be specified explicitly).
        po::options_description visible_options("");
        visible_options.add_options()
            ("color", _("Enable color output.").c_str())
            ("config,c", po::value<string>(), _("The location of the config file.").c_str())
            ("custom-dir", po::value<vector<string>>(), _("A directory to use for custom facts.").c_str())
            ("debug,d", po::bool_switch()->default_value(false), _("Enable debug output.").c_str())
            ("external-dir", po::value<vector<string>>(), _("A directory to use for external facts.").c_str())
            ("help,h", _("Print this help message.").c_str())
            ("json,j", _("Output in JSON format.").c_str())
            ("list-block-groups", _("List the names of all blockable fact groups.").c_str())
            ("list-cache-groups", _("List the names of all cacheable fact groups.").c_str())
            ("log-level,l", po::value<level>()->default_value(level::warning, "warn"), _("Set logging level.\nSupported levels are: none, trace, debug, info, warn, error, and fatal.").c_str())
            ("no-block", _("Disable fact blocking.").c_str())
            ("no-cache", _("Disable loading and refreshing facts from the cache").c_str())
            ("no-color", _("Disable color output.").c_str())
            ("no-custom-facts", po::bool_switch()->default_value(false), _("Disable custom facts.").c_str())
            ("no-external-facts", po::bool_switch()->default_value(false), _("Disable external facts.").c_str())
            ("no-ruby", po::bool_switch()->default_value(false), _("Disable loading Ruby, facts requiring Ruby, and custom facts.").c_str())
            ("puppet,p", _("Load the Puppet libraries, thus allowing Facter to load Puppet-specific facts.").c_str())
            ("show-legacy", _("Show legacy facts when querying all facts.").c_str())
            ("trace", po::bool_switch()->default_value(false), _("Enable backtraces for custom facts.").c_str())
            ("verbose", po::bool_switch()->default_value(false), _("Enable verbose (info) output.").c_str())
            ("version,v", _("Print the version and exit.").c_str())
            ("yaml,y", _("Output in YAML format.").c_str())
            ("strict", _("Enable more aggressive error reporting.").c_str());
        return visible_options;
    }

    void load_cli_options(po::variables_map &vm, po::options_description &visible_options, int argc, char **argv)
    {
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

        po::store(po::command_line_parser(argc, argv).
            options(command_line_options).positional(positional_options).run(), vm);
    }

    std::set<std::string> sanitize_cli_queries(std::vector<std::string> query)
    {
        // Build a set of queries from the command line
        set<string> queries;
        for (auto const &q : query) {
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
        return queries;
    }
}}}  // namespace facter::util::cli;
