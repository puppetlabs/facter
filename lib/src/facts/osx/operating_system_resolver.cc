#include <internal/facts/osx/operating_system_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/execution/execution.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <boost/algorithm/string.hpp>
#include <string>

using namespace std;
using namespace facter::facts;
using namespace facter::execution;

namespace facter { namespace facts { namespace osx {

    operating_system_resolver::data operating_system_resolver::collect_data(collection& facts)
    {
        // Default to the base implementation
        data result = posix::operating_system_resolver::collect_data(facts);

        execution::each_line("/usr/bin/sw_vers", [&](string& line) {
            // Split at the first ':'
            auto pos = line.find(':');
            if (pos == string::npos) {
                return true;
            }
            string key = line.substr(0, pos);
            boost::trim(key);
            string value = line.substr(pos + 1);
            boost::trim(value);

            if (key == "ProductName") {
                result.osx.product = move(value);
            } else if (key == "BuildVersion") {
                result.osx.build = move(value);
            } else if (key == "ProductVersion") {
                result.osx.version = move(value);
            }

            // Populate the major and minor version facts using kernel_release
            auto release = facts.get<string_value>(fact::kernel_release);

            if (!release->value().empty()) {
                result.release = move(release->value());
                auto pos = release->value().find('.');
                if (pos != string::npos) {
                    auto second = release->value().find('.', pos + 1);
                    result.major = release->value().substr(0, pos);
                    result.minor = release->value().substr(pos + 1, second - (pos + 1));
                }
            }

            // Continue only if we haven't populated the data
            return result.osx.product.empty() || result.osx.build.empty() || result.osx.version.empty() || result.release.empty();
        });

        return result;
    }

}}}  // namespace facter::facts::osx
