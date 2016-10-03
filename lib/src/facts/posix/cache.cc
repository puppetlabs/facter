#include <internal/facts/cache.hpp>

namespace facter { namespace facts { namespace cache {

    std::string fact_cache_location() {
        return "/opt/puppetlabs/facter/cache/cached_facts/";
    }

}}}  // namespace facter::facts::cache
