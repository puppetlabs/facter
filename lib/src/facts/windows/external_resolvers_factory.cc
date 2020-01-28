#include <facter/facts/external_resolvers_factory.hpp>
#include <internal/facts/external/windows/powershell_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>

using namespace std;
using namespace boost::filesystem;

namespace facter { namespace facts {
    bool external_resolvers_factory::powershell_resolver_can_resolve(string const& file)
    {
        try {
            path p = file;
            return boost::iends_with(file, ".ps1") && is_regular_file(p);
        } catch (filesystem_error &e) {
            LOG_TRACE("error reading status of path {1}: {2}", file, e.what());
            return false;
        }
    }
    shared_ptr<external::resolver> external_resolvers_factory::get_resolver(const string& path) {
      auto resolver = get_common_resolver(path);
      if (resolver)
        return resolver;
      if (powershell_resolver_can_resolve(path)) {
        return make_shared<external::powershell_resolver>(path);
      }

      throw external::external_fact_no_resolver(leatherman::locale::_("No resolver for external facts file {1}", path));
    }

}}  // namespace facter::facts
