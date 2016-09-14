#include "collection_fixture.hpp"

namespace facter { namespace testing {

    using namespace std;

    collection_fixture::collection_fixture(set<string> const& blocklist,
            unordered_map<string, int64_t> const& ttls) : collection(blocklist, ttls) { }

    vector<string> collection_fixture::get_external_fact_directories() const
    {
        return {};
    }

}}  // namespace facter::testing
