#include <facter/util/config.hpp>
#include <hocon/program_options.hpp>
#include <leatherman/file_util/file.hpp>
#include <facter/logging/logging.hpp>

using namespace std;
using namespace hocon;
namespace po = boost::program_options;

namespace facter { namespace util { namespace config {

    shared_config load_config_from(string config_path) {
        if (leatherman::file_util::file_readable(config_path)) {
            return hocon::config::parse_file_any_syntax(config_path)->resolve();
        }
        return nullptr;
    }

    void load_global_settings(shared_config hocon_config, po::variables_map& vm) {
        if (hocon_config && hocon_config->has_path("global")) {
            auto global_settings = hocon_config->get_object("global")->to_config();
            po::store(hocon::program_options::parse_hocon<char>(global_settings, global_config_options(), true), vm);
        }
    }

    void load_cli_settings(shared_config hocon_config, po::variables_map& vm) {
        if (hocon_config && hocon_config->has_path("cli")) {
            auto cli_settings = hocon_config->get_object("cli")->to_config();
            po::store(hocon::program_options::parse_hocon<char>(cli_settings, cli_config_options(), true), vm);
        }
    }

    void load_fact_settings(shared_config hocon_config, po::variables_map& vm) {
        if (hocon_config && hocon_config->has_path("facts")) {
            auto fact_settings = hocon_config->get_object("facts")->to_config();
            po::store(hocon::program_options::parse_hocon<char>(fact_settings, fact_config_options(), true), vm);
        }
    }

    void load_fact_groups_settings(shared_config hocon_config, po::variables_map& vm) {
        if (hocon_config && hocon_config->has_path("fact-groups")) {
            auto fact_groups_settings = hocon_config->get_object("fact-groups")->to_config();
            po::store(hocon::program_options::parse_hocon<char>(fact_groups_settings, fact_groups_config_options(), true), vm);
        }
    }

    po::options_description global_config_options() {
        po::options_description global_options("");
        global_options.add_options()
            ("custom-dir", po::value<vector<string>>(), "A directory or list of directories to use for custom facts.")
            ("external-dir", po::value<vector<string>>(), "A directory or list of directories to use for external facts.")
            ("no-custom-facts", po::value<bool>()->default_value(false), "Disables custom facts.")
            ("no-external-facts", po::value<bool>()->default_value(false), "Disables external facts.")
            ("no-ruby", po::value<bool>()->default_value(false), "Disables loading Ruby, facts requiring Ruby, and custom facts.");
        return global_options;
    }

    po::options_description cli_config_options() {
        po::options_description cli_options("");
        cli_options.add_options()
            ("debug", po::value<bool>()->default_value(false), "Enable debug output.")
            ("log-level", po::value<logging::level>()->default_value(logging::level::warning, "warn"), "Set logging level.\nSupported levels are: none, trace, debug, info, warn, error, and fatal.")
            ("trace", po::value<bool>()->default_value(false), "Enable backtraces for custom facts.")
            ("verbose", po::value<bool>()->default_value(false), "Enable verbose (info) output.");
        return cli_options;
    }

    po::options_description fact_config_options() {
        po::options_description fact_settings("");
        fact_settings.add_options()
            ("blocklist", po::value<vector<string>>(), "A set of facts to block.");
        return fact_settings;
    }

    po::options_description fact_groups_config_options() {
        po::options_description fact_groups_settings("");
        fact_groups_settings.add_options()
            ("cached-custom-facts", po::value<vector<string>>(), "A list of custom facts to be cached.");
        return fact_groups_settings;
    }

    unordered_map<string, int64_t> load_ttls(shared_config hocon_config) {
        unordered_map<string, int64_t> ttls;
        if (hocon_config && hocon_config->has_path("facts.ttls")) {
            auto ttl_objs = hocon_config->get_object_list("facts.ttls");
            for (auto entry : ttl_objs) {
                shared_config entry_conf = entry->to_config();
                // triple-quote this string so that cpp-hocon will correctly parse it as a single path element
                // and ignore otherwise reserved characters
                string fact = entry->key_set().front();
                int64_t duration = entry_conf->get_duration("\"\"\"" + fact + "\"\"\"", time_unit::SECONDS);
                ttls.insert({ fact, duration });
            }
        }
        return ttls;
    }
}}}  // namespace facter::util::config;
