#include <leatherman/locale/locale.hpp>
#include <facter/facts/external_resolvers_factory.hpp>

using namespace std;
namespace facter { namespace facts {
    shared_ptr<external::resolver> external_resolvers_factory::get_resolver(const string& path) {
      auto resolver = get_common_resolver(path);
      if (resolver)
        return resolver;
      throw external::external_fact_no_resolver(leatherman::locale::_("No resolver for external facts file {1}", path));
    }
}}  // facter::facts
