#include <facter/facts/external_resolvers_factory.hpp>
#include <leatherman/execution/execution.hpp>
#include <boost/algorithm/string.hpp>

#include <internal/facts/external/json_resolver.hpp>
#include <internal/facts/external/text_resolver.hpp>
#include <internal/facts/external/yaml_resolver.hpp>
#include <internal/facts/external/execution_resolver.hpp>


using namespace std;
namespace facter { namespace facts {

    bool external_resolvers_factory::text_resolver_can_resolve(string const &path) {
      return boost::iends_with(path, ".txt");
    }

    bool external_resolvers_factory::json_resolver_can_resolve(string const &path) {
      return boost::iends_with(path, ".json");
    }

    bool external_resolvers_factory::yaml_resolver_can_resolve(string const &path) {
      return boost::iends_with(path, ".yaml");
    }

    bool external_resolvers_factory::execution_resolver_can_resolve(string const &path) {
      return !leatherman::execution::which(path, {}).empty();
    }

    shared_ptr<external::resolver> external_resolvers_factory::get_common_resolver(const string& path)
    {
      if (text_resolver_can_resolve(path)) {
        return make_shared<external::text_resolver>(path);
      }
      if (json_resolver_can_resolve(path)) {
        return make_shared<external::json_resolver>(path);
      }
      if (yaml_resolver_can_resolve(path)) {
        return make_shared<external::yaml_resolver>(path);
      }
      if (execution_resolver_can_resolve(path)) {
        return make_shared<external::execution_resolver>(path);
      }
      return NULL;
    }

}}  // namespace facter::facts
