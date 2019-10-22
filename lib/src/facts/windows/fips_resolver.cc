#include <internal/facts/windows/fips_resolver.hpp>
#include <leatherman/windows/registry.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/lexical_cast.hpp>

using namespace std;

using boost::lexical_cast;
using boost::bad_lexical_cast;
using namespace leatherman::windows;

namespace facter { namespace facts { namespace windows {

    fips_resolver::data fips_resolver::collect_data(collection& facts)
    {
        data result;

        // Set a safe default
        result.is_fips_mode_enabled = false;
        unsigned long enabled;
        try {
            enabled = registry::get_registry_dword(registry::HKEY::LOCAL_MACHINE,
                "System\\CurrentControlSet\\Control\\Lsa\\FipsAlgorithmPolicy\\", "Enabled");
            result.is_fips_mode_enabled = enabled != 0;
        } catch (registry_exception &e) {
            LOG_DEBUG("failure getting fips_mode: {1}", e.what());
        }
        return result;
    }

}}}  // namespace facter::facts::windows
