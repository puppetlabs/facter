#include "collection_fixture.hpp"

namespace facter { namespace testing {

    using namespace std;

    vector<string> collection_fixture::get_external_fact_directories() const
    {
        return {};
    }

}}  // namespace facter::testing
