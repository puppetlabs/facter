#include <internal/facts/aix/serial_number_resolver.hpp>
#include <internal/util/aix/odm.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/regex.hpp>

#include <sys/cfgodm.h>

using namespace std;
using namespace facter::util::aix;
using namespace leatherman::util;

namespace facter { namespace facts { namespace aix {

    serial_number_resolver::serial_number_resolver() :
        resolver(
            "AIX serial number",
            {
                fact::serial_number,
            })
    {
    }

    void serial_number_resolver::resolve(collection& facts, set<string> const& blocklist) {
        auto cu_at_query = odm_class<CuAt>::open("CuAt").query("name=sys0 and attribute=systemid");
        auto result = *cu_at_query.begin();

        // the ODM returns a string of the form "IBM,XXSERIAL#". We
        // need to strip the "IBM,XX" from the start ofthis, and keep
        // only the 7 actual serial number bytes.
        const auto regex = boost::regex("^IBM,\\d\\d(.+)");
        string serial;
        if (re_search(string(result.value), regex, &serial)) {
            facts.add(fact::serial_number, make_value<string_value>(move(serial), true));
        } else {
            LOG_DEBUG("Could not retrieve serial number: sys0 systemid did not match the expected format");
        }
    }

}}}  // namespace facter::facts::aix
