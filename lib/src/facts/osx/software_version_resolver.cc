#include <facter/facts/osx/software_version_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string.hpp>
#include <map>
#include <string>

using namespace std;
using namespace facter::facts;
using namespace facter::execution;

namespace facter { namespace facts { namespace osx {

    software_version_resolver::software_version_resolver() :
        resolver(
            "software version",
            {
                fact::macosx_buildversion,
                fact::macosx_productname,
                fact::macosx_productversion,
                fact::macosx_productversion_major,
                fact::macosx_productversion_minor,
            })
    {
    }

    void software_version_resolver::resolve(collection& facts)
    {
        static map<string, string> fact_names = {
            { "ProductName",    string(fact::macosx_productname) },
            { "ProductVersion", string(fact::macosx_productversion) },
            { "BuildVersion",   string(fact::macosx_buildversion) },
        };

        size_t count = 0;
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

            // Lookup the fact name based on the "key"
            auto fact_name = fact_names.find(key);
            if (fact_name == fact_names.end()) {
                return true;
            }
            // If this is the product version, split out the major and minor versions
            if (fact_name->second == fact::macosx_productversion) {
                // Look for the last '.' for major/minor
                auto pos = value.rfind('.');
                if (pos != string::npos) {
                    string major = value.substr(0, pos);
                    string minor = value.substr(pos + 1);

                    // If the major doesn't have a '.', treat the entire version as the major
                    // and use a minor of "0"
                    if (major.find('.') == string::npos) {
                        major = value;
                        minor = "0";
                    }
                    facts.add(fact::macosx_productversion_major, make_value<string_value>(move(major)));
                    facts.add(fact::macosx_productversion_minor, make_value<string_value>(move(minor)));
                }
            }
            facts.add(string(fact_name->second), make_value<string_value>(move(value)));
            // Continue only if we haven't added all the facts
            return ++count < fact_names.size();
        });
    }

}}}  // namespace facter::facts::osx
