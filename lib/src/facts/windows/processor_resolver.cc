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

        auto vals = _wmi.query(wmi::processor, {wmi::numberoflogicalprocessors, wmi::name});

        for (auto const& objs : vals) {
            logical_count += stoi(wmi::get(objs, wmi::numberoflogicalprocessors));
            models.emplace_back(wmi::get(objs, wmi::name));
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
