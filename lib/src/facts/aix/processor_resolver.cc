#include <internal/facts/aix/processor_resolver.hpp>
#include <internal/util/aix/odm.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/util/scope_exit.hpp>

#include <cstdint>
#include <stdexcept>
#include <odmi.h>
#include <sys/cfgodm.h>

using namespace std;
using namespace facter::util::aix;

struct physical_processor
{
     string type;
     long long frequency;
     int smt_threads;
     bool smt_enabled;
};

namespace facter { namespace facts { namespace aix {

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        auto result = posix::processor_resolver::collect_data(facts);

        // On AIX, we query the object data manager (odm) for
        // processor information. This is a semi-hierarchical
        // datastore of all the information about the system. For
        // processors, we need to go through three links:
        //
        // 1. We query for all "predefined devices" with the
        // "processor" class. I don't know if it's actually possible
        // to get more than one result here - on the Puppet LPARs
        // there is only one.
        //
        // 2. For each predefined device, we query the "custom
        // devices". These represent the actual processors in the
        // machine.
        //
        // 3. For each custom device, we query its attributes. These
        // are things like frequency, type, and SMT information.

        vector<string> processor_types;
        auto pd_dv_query = odm_class<PdDv>::open("PdDv").query("class=processor");
        for (auto& pd_dv : pd_dv_query) {
            LOG_DEBUG("got a processor type: %1%", pd_dv.uniquetype);
            processor_types.push_back(pd_dv.uniquetype);
        }

        vector<string> processor_names;
        for (string& type : processor_types) {
            string query = (boost::format("PdDvLn=%1%") % type).str();
            auto cu_dv_query = odm_class<CuDv>::open("CuDv").query(query);
            for (auto& cu_dv : cu_dv_query) {
                LOG_DEBUG("got a processor: %1%", cu_dv.name);
                processor_names.push_back(cu_dv.name);
            }
        }

        for (string& name : processor_names) {
            string query = (boost::format("name=%1%") % name).str();
            physical_processor proc;
            auto cu_at_query = odm_class<CuAt>::open("CuAt").query(query);
            for (auto& cu_at : cu_at_query) {
                LOG_DEBUG("got attribute %1%=%2% for processor %3%", cu_at.attribute, cu_at.value, name);
                if (cu_at.attribute == string("frequency")) {
                    proc.frequency = stoll(cu_at.value);
                } else if (cu_at.attribute == string("type")) {
                    proc.type = cu_at.value;
                } else if (cu_at.attribute == string("smt_threads")) {
                    proc.smt_threads = stoi(cu_at.value);
                } else if (cu_at.attribute == string("smt_enabled")) {
                    proc.smt_enabled = (cu_at.value == string("true"));
                } else {
                    LOG_INFO("don't know what to do with processor attribute %1%", cu_at.attribute)
                }
            }

            if (result.speed == 0) {
                result.speed = proc.frequency;
            } else if (result.speed != proc.frequency) {
                LOG_WARNING("mismatched processor frequencies found; facter will only report one of them");
            }

            if (proc.smt_enabled) {
                result.logical_count += proc.smt_threads;
                vector<string> types(proc.smt_threads, proc.type);
                result.models.insert(result.models.begin(),
                                     make_move_iterator(types.begin()),
                                     make_move_iterator(types.end()));
            } else {
                result.logical_count += 1;
                result.models.push_back(move(proc.type));
            }
        }

        return result;
    }
}}}  // namespace facter::facts::aix
