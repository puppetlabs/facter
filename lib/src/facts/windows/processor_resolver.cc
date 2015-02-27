#include <facter/facts/windows/processor_resolver.hpp>
#include <facter/util/windows/wmi.hpp>
#include <facter/util/regex.hpp>
#include <facter/logging/logging.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;

namespace facter { namespace facts { namespace windows {

    processor_resolver::processor_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::processor_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    // Returns physical_count, logical_count, models, isa, speed
    static tuple<int, int, vector<string>, string, int64_t> get_processors(wmi const& _wmi)
    {
        vector<string> models;
        string isa;
        int logical_count = 0;

        auto names = _wmi.query(wmi::processor, {wmi::name});
        for (auto const& nameobj : names) {
            models.emplace_back(wmi::get(nameobj, wmi::name));
        }

        // Query number of logical processors separately; it's not supported on Server 2003, and will cause
        // the entire query to return empty if used.
        auto logicalprocs = _wmi.query(wmi::processor, {wmi::numberoflogicalprocessors});
        for (auto const& objs : logicalprocs) {
            logical_count += stoi(wmi::get(objs, wmi::numberoflogicalprocessors));
        }

        if (logical_count == 0) {
            logical_count = models.size();
        }

        // Query for architecture and transform numerical ID into a string based on
        // https://msdn.microsoft.com/en-us/library/aa394373%28v=vs.85%29.aspx.
        // Use the architecture of the first result.
        auto arch_id = _wmi.query(wmi::processor, {wmi::architecture});
        if (!arch_id.empty()) {
            int architecture = stoi(wmi::get(arch_id.front(), wmi::architecture));

            switch (architecture) {
                case 0:
                    isa = "x86";
                    break;
                case 1:
                    isa = "MIPS";
                    break;
                case 2:
                    isa = "Alpha";
                    break;
                case 3:
                    isa = "PowerPC";
                    break;
                case 5:
                    isa = "ARM";
                    break;
                case 6:
                    isa = "Itanium-based systems";
                    break;
                case 9:
                    isa = "x64";
                    break;
                default:
                    LOG_DEBUG("Unable to determine processor type: unknown architecture");
                    isa = "";
                    break;
            }
        } else {
            LOG_DEBUG("WMI processor Architecture query returned no results.");
            isa = "";
        }

        return make_tuple(models.size(), logical_count, move(models), move(isa), 0);
    }

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        data result;
        tie(result.physical_count, result.logical_count, result.models, result.isa, result.speed) = get_processors(*_wmi);
        return result;
    }

}}}  // namespace facter::facts::windows
