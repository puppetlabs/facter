#include <facter/config/config.hpp>

using namespace std;

namespace facter { namespace config {

    config::config(hocon::shared_config hocon_conf) : _config(hocon_conf) { }

    config config::instance(string const& file_path) {
        static config conf(hocon::config::parse_file_any_syntax(file_path)->resolve());
        return conf;
    }

    void config::reload_from_file(std::string const& file_path) {
        _config = hocon::config::parse_file_any_syntax(file_path)->resolve();
    }

    bool config::has_setting(string const& setting_path) {
        return _config->has_path(setting_path);
    }

}}  // namespace facter::config

