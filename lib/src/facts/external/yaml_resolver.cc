#include <internal/facts/external/yaml_resolver.hpp>
#include <internal/util/yaml.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/nowide/fstream.hpp>
#include <yaml-cpp/yaml.h>
#include <yaml-cpp/eventhandler.h>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;
using namespace YAML;
using namespace facter::util::yaml;

namespace facter { namespace facts { namespace external {

    bool yaml_resolver::can_resolve(string const& path) const
    {
        return boost::iends_with(path, ".yaml");
    }

    void yaml_resolver::resolve(string const& path, collection& facts) const
    {
        LOG_DEBUG("resolving facts from YAML file \"{1}\".", path);

        boost::nowide::ifstream stream(path.c_str());
        if (!stream) {
            throw external_fact_exception(_("file could not be opened."));
        }

        try {
            Node node = YAML::Load(stream);
            for (auto const& kvp : node) {
                add_value(kvp.first.as<string>(), kvp.second, facts);
            }
        } catch (Exception& ex) {
            throw external_fact_exception(ex.msg);
        }

        LOG_DEBUG("completed resolving facts from YAML file \"{1}\".", path);
    }

}}}  // namespace facter::facts::external
