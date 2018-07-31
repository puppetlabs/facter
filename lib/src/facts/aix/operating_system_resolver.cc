#include <internal/facts/aix/operating_system_resolver.hpp>
#include <internal/util/aix/odm.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/os.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/logging/logging.hpp>

#include <boost/algorithm/string.hpp>
#include <odmi.h>
#include <sys/cfgodm.h>

using namespace std;
using namespace facter::util::aix;

// This routine's meant to be a general utility function that replicates the behavior of
// lsattr -El <object> -a <field>. Although it's only used to get the modelname of the
// sys0 device, we still would like to have it here in case we ever need to separate it
// out to an AIX utils file to query other attributes. Part of what lsattr does is check
// PdAt if we don't have an entry for the object's attribute in CuAt, even though it is very
// unlikely that sys0.modelname will not have a CuAt entry. That is why we have the extra code
// in here.
static string getattr(string object, string field)
{
    // High-level logic here is:
    //   * Check if there's an entry for our object's field attribute in CuAt (the device-specific
    //   attribute entry).
    //
    //   * Else, check for the field attribute's default value in PdAt. We do this by first
    //   figuring out the PdDv type from the CuDv entry for the object, then use our PdDv type
    //   to query the field's default value in PdAt.
    string query = (boost::format("name = %1% AND attribute = %2%") % object % field).str();
    auto cuat_query = odm_class<CuAt>::open("CuAt").query(query);

    // This is a more verbose way of saying that we only expect our query to have one element
    auto cuat_ref = cuat_query.begin();
    if (cuat_ref != cuat_query.end()) {
      auto value = string(cuat_ref->value);
      if (value.empty()) {
        LOG_DEBUG("Could not get a value from the ODM for {1}'s '{2}' attribute.", object, field);
      }
      return value;
    }

    // Get the PdDv type from the CuDv entry
    query = (boost::format("name = %1%") % object).str();
    auto cudv_query = odm_class<CuDv>::open("CuDv").query(query);
    auto cudv_ref = cudv_query.begin();
    if (cudv_ref == cudv_query.end()) {
      LOG_DEBUG("Could not get a value from the ODM for {1}'s '{2}' attribute: There is no CuDv entry for {1}.", object, field);
      return "";
    }
    auto pddv_type = cudv_ref->PdDvLn_Lvalue;

    query = (boost::format("uniquetype = %1% AND attribute = %2%") % pddv_type % field).str();
    auto pdat_query = odm_class<PdAt>::open("PdAt").query(query);
    auto pdat_ref = pdat_query.begin();
    if (pdat_ref != pdat_query.end()) {
      auto value = string(pdat_ref->deflt);
      if (value.empty()) {
        LOG_DEBUG("Could not get a value from the ODM for {1}'s '{2}' attribute.", object, field);
      }
      return value;
    }

    LOG_DEBUG("Could not get a value from the ODM for {1}'s '{2}' attribute: There is no PdAt entry for {1} with {2}.", object, field);
    return "";
}

namespace facter { namespace facts { namespace aix {

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        auto result = posix::operating_system_resolver::collect_data(facts);

        // on AIX, major version is hyphen-delimited. The base
        // resolver can't figure this out for us.
        vector<string> tokens;
        boost::split(tokens, result.release, boost::is_any_of("-"));
        result.major = tokens[0];

        // Get the hardware
        result.hardware = getattr("sys0", "modelname");

        // Now get the architecture. We use processor.models[0] for this information.
        auto processors = facts.get<map_value>(fact::processors);
        auto models = processors ? processors->get<array_value>("models") : nullptr;
        if (! models || models->empty()) {
          LOG_DEBUG("Could not get a value for the OS architecture. Your machine does not have any processors!");
        } else {
          result.architecture = models->get<string_value>(0)->value();
        }

        return result;
    }
}}}
