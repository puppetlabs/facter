#include <internal/facts/solaris/ldom_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>
#include <facter/facts/map_value.hpp>
#include <boost/algorithm/string.hpp>
#include <string>
#include <vector>

using namespace std;
using namespace facter::facts;
using namespace leatherman::execution;
using namespace leatherman::util;

namespace facter { namespace facts { namespace solaris {

    ldom_resolver::data ldom_resolver::collect_data(collection& facts)
    {
        /*
           Convert virtinfo parseable output format to array of arrays.
           DOMAINROLE|impl=LDoms|control=true|io=true|service=true|root=true
           DOMAINNAME|name=primary
           DOMAINUUID|uuid=8e0d6ec5-cd55-e57f-ae9f-b4cc050999a4
           DOMAINCONTROL|name=san-t2k-6
           DOMAINCHASSIS|serialno=0704RB0280

           For keys containing multiple value such as domain role:
           ldom_{key}_{subkey} = value
           Otherwise the fact will simply be:
           ldom_{key} = value
        */
        data result;

        auto isa = facts.get<string_value>(fact::hardware_isa);
        if (isa && isa->value() != "sparc") {
            return result;
        }

        each_line("/usr/sbin/virtinfo", { "-a", "-p" }, [&] (string& line) {
            if (!re_search(line, boost::regex("^DOMAIN"))) {
                return true;
            }

            vector<string> items;
            boost::split(items, line, boost::is_any_of("|"));

            // The first element is the key, i.e, "domainrole." Subsequent entries are values.
            if (items.empty()) {
                return true;
            } else if (items.size() == 2) {
                ldom_info ldom_data;
                string key = items[0];
                string value = items[1].substr(items[1].find("=") + 1);

                transform(key.begin(), key.end(), key.begin(), ::tolower);

                ldom_data.key = key;
                ldom_data.values.insert({ key, value });
                result.ldom.emplace_back(ldom_data);
            } else {
                // When there are multiple values to a line, we insert them all in a single sub-map.
                ldom_info ldom_data;
                string base_key = items[0];  // Base key is used as top level sub-key in the structured fact
                transform(base_key.begin(), base_key.end(), base_key.begin(), ::tolower);
                ldom_data.key = base_key;

                items.erase(items.begin());

                for (string val : items) {
                    auto pos = val.find("=");
                    string sub_key = val.substr(0, pos);
                    string value = val.substr(pos + 1);

                    ldom_data.values.insert({ sub_key, value });
                }

                result.ldom.emplace_back(ldom_data);
            }
            return true;
        });

        return result;
    }

}}}  // namespace facter::facts::solaris
