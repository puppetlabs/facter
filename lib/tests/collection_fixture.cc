#include "collection_fixture.hpp"

namespace facter { namespace testing {

    using namespace std;

    collection_fixture::collection_fixture(set<string> const& blocklist) : collection(blocklist) { }

    vector<string> collection_fixture::get_external_fact_directories() const
    {
        return {};
    }

}}  // namespace facter::testing
