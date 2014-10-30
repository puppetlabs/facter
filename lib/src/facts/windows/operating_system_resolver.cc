#include <facter/facts/windows/operating_system_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/util/regex.hpp>
#include <facter/util/windows/wmi.hpp>
#include <map>

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;

namespace facter { namespace facts { namespace windows {

    operating_system_resolver::operating_system_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::operating_system_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        data result = resolvers::operating_system_resolver::collect_data(facts);

        auto lastDot = result.release.rfind('.');
        if (lastDot == string::npos) {
            return result;
        }

        auto vals = _wmi->query(wmi::operatingsystem, {wmi::producttype, wmi::othertypedescription});
        if (vals.empty()) {
            return result;
        }

        // Override default release with Windows release names
        auto version = result.release.substr(0, lastDot);
        bool consumerrel = (wmi::get(vals, wmi::producttype) == "1");
        if (version == "6.4") {
            result.release = consumerrel ? "10" : result.release;
        } else if (version == "6.3") {
            result.release = consumerrel ? "8.1" : "2012 R2";
        } else if (version == "6.2") {
            result.release = consumerrel ? "8" : "2012";
        } else if (version == "6.1") {
            result.release = consumerrel ? "7" : "2008 R2";
        } else if (version == "6.0") {
            result.release = consumerrel ? "Vista" : "2008";
        } else if (version == "5.2") {
            if (consumerrel) {
                result.release = "XP";
            } else {
                result.release = (wmi::get(vals, wmi::othertypedescription) == "R2") ? "2003 R2" : "2003";
            }
        }

        return result;
    }

}}}  // namespace facter::facts::windows
