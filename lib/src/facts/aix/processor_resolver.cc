#include <internal/facts/aix/processor_resolver.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/util/scope_exit.hpp>

#include <cstdint>
#include <stdexcept>
#include <odmi.h>
#include <sys/cfgodm.h>

using namespace std;

// unlike just about every other error code to string function in the
// world, odm_err_msg doesn't just return its pointer - it wants a
// char** argument to put it in. This wraps that ugly API in a more
// strerror()-like interface for ease of use.
static const char* odm_error_string() {
    static char* msg;
    int result = odm_err_msg(odmerrno, &msg);
    if (result < 0) {
        return "failed to retrieve ODM error message";
    } else {
        return msg;
    }
}

// ODM return value handling is kind of gross, so this saves us from
// it a bit.  Even though it nominally returns a pointer, it can have
// the value "-1" on error. In that case, we want to get the error
// string and throw an exception. This handles all of that in all the
// places we need it.
#define check_odm_return(var, msg) if (reinterpret_cast<intptr_t>(var) == -1) { throw runtime_error((boost::format(msg ": %1%") % odm_error_string()).str()); }

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

        if (odm_initialize() < 0) {
            throw runtime_error((boost::format("failed to initialize ODM: %1%") % odm_error_string()).str());
        }
        leatherman::util::scope_exit cleanup(odm_terminate);

        CLASS_SYMBOL PdDv_class = odm_mount_class(const_cast<char*>("PdDv"));
        CLASS_SYMBOL CuDv_class = odm_mount_class(const_cast<char*>("CuDv"));
        CLASS_SYMBOL CuAt_class = odm_mount_class(const_cast<char*>("CuAt"));
        check_odm_return(PdDv_class, "couldn't mount PdDv ODM class");
        check_odm_return(CuDv_class, "couldn't mount CuDv ODM class");
        check_odm_return(CuAt_class, "couldn't mount CuAt ODM class");

        vector<string> processor_types;
        PdDv* predefined_processor = static_cast<PdDv*>(odm_get_first(PdDv_class, const_cast<char*>("class=processor"), nullptr));
        while (predefined_processor) {
            check_odm_return(predefined_processor, "could not fetch processor types from PvDv");
            LOG_DEBUG("got a processor type: %1%", predefined_processor->uniquetype);
            processor_types.push_back(predefined_processor->uniquetype);
            free(predefined_processor);
            predefined_processor = static_cast<PdDv*>(odm_get_next(PdDv_class, nullptr));
        }

        vector<string> processor_names;
        for (string& type : processor_types) {
            string query = (boost::format("PdDvLn=%1%") % type).str();
            CuDv* processor = static_cast<CuDv*>(odm_get_first(CuDv_class, const_cast<char*>(query.c_str()), nullptr));
            while (processor) {
                check_odm_return(processor, "could not fetch processors from CuDv");
                LOG_DEBUG("got a processor: %1%", processor->name);
                processor_names.push_back(processor->name);
                free(processor);
                processor = static_cast<CuDv*>(odm_get_next(CuDv_class, nullptr));
            }
        }

        for (string& name : processor_names) {
            string query = (boost::format("name=%1%") % name).str();
            physical_processor proc;
            CuAt* attribute = static_cast<CuAt*>(odm_get_first(CuAt_class, const_cast<char*>(query.c_str()), nullptr));
            while (attribute) {
                check_odm_return(attribute, "Could not fetch processor attributes from CuAt");
                LOG_DEBUG("got attribute %1%=%2% for processor %3%", attribute->attribute, attribute->value, name);
                if (attribute->attribute == string("frequency")) {
                    proc.frequency = stoll(attribute->value);
                } else if (attribute->attribute == string("type")) {
                    proc.type = attribute->value;
                } else if (attribute->attribute == string("smt_threads")) {
                    proc.smt_threads = stoi(attribute->value);
                } else if (attribute->attribute == string("smt_enabled")) {
                    proc.smt_enabled = (attribute->value == string("true"));
                } else {
                    LOG_INFO("don't know what to do with processor attribute %1%", attribute->attribute)
                }
                free(attribute);
                attribute = static_cast<CuAt*>(odm_get_next(CuAt_class, nullptr));
            }

            result.physical_count++;

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
