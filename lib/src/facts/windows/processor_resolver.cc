#include <facter/facts/windows/processor_resolver.hpp>
#include <facter/util/windows/wmi.hpp>
#include <facter/util/regex.hpp>
#include <boost/range/irange.hpp>
#include <boost/range/iterator_range.hpp>
#include <boost/algorithm/string/trim.hpp>

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

        auto num_logical_procs = boost::make_iterator_range(vals.equal_range(wmi::numberoflogicalprocessors));
        if (num_logical_procs.empty()) {
            logical_count = 1;
        } else {
            for (auto const& kv : num_logical_procs) {
                logical_count += stoi(kv.second);
            }
        }

        auto proc_names = boost::make_iterator_range(vals.equal_range(wmi::name));
        for (auto const& kv : proc_names) {
            models.emplace_back(boost::trim_copy(kv.second));
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
