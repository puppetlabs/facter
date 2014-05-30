#include <facter/facts/external/resolver.hpp>

using namespace std;

namespace facter { namespace facts { namespace external {

    external_fact_exception::external_fact_exception(string const& message) :
        runtime_error(message)
    {
    }

}}}  // namespace facter::facts::external
