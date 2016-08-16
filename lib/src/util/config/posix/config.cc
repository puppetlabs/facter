#include <facter/util/config.hpp>

namespace facter { namespace util { namespace config {

    hocon::shared_config load_default_config_file() {
        return load_config_from("/etc/puppetlabs/facter/facter.conf");
    }
}}}  // namespace facter::util::config
