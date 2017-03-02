#include <internal/facts/cache.hpp>
#include <leatherman/windows/file_util.hpp>

namespace facter { namespace facts { namespace cache {

    std::string fact_cache_location() {
        return leatherman::windows::file_util::get_programdata_dir() +
            "\\PuppetLabs\\facter\\cache\\cached_facts\\";
    }

}}}  // namespace facter::facts::cache
