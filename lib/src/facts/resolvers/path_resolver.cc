#include <internal/facts/resolvers/path_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/fact.hpp>
#include <facter/util/environment.hpp>

using namespace std;
using namespace facter::util;

namespace facter { namespace facts { namespace resolvers {

    path_resolver::path_resolver() :
        resolver("path", {fact::path})
    {
    }

    void path_resolver::resolve(collection& facts)
    {
        string path_val;
        if (environment::get("PATH", path_val)) {
            facts.add(fact::path, make_value<string_value>(move(path_val)));
        }
    }

}}}  // namespace facter::facts::resolvers
