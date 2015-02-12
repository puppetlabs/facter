#include <facter/facts/windows/processor_resolver.hpp>
#include <facter/util/windows/wmi.hpp>
#include <facter/util/regex.hpp>

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;

namespace facter { namespace facts { namespace windows {

    processor_resolver::processor_resolver(shared_ptr<wmi> wmi_conn) :
        resolvers::processor_resolver(),
        _wmi(move(wmi_conn))
    {
    }

    // Returns physical_count, logical_count, models, speed
    static tuple<int, int, vector<string>, int64_t> get_processors(wmi const& _wmi)
    {
        vector<string> models;
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

        return make_tuple(models.size(), logical_count, move(models), 0);
    }

    processor_resolver::data processor_resolver::collect_data(collection& facts)
    {
        data result;
        tie(result.physical_count, result.logical_count, result.models, result.speed) = get_processors(*_wmi);
        return result;
    }

}}}  // namespace facter::facts::windows
