#include <internal/facts/aix/nim_resolver.hpp>
#include <internal/util/aix/odm.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>
#include <boost/regex.hpp>

#include <sys/cfgodm.h>

using namespace std;
using namespace facter::util::aix;
using namespace leatherman::util;
using namespace leatherman::execution;
using namespace facter::facts;

namespace facter { namespace facts { namespace aix {

    nim_resolver::nim_resolver() :
        resolver(
            "AIX NIM type",
            {
                fact::nim_type,
            })
    {
    }

    string nim_resolver::read_niminfo() {
        auto exec = execute("cat", {"/etc/niminfo"});
        if (!exec.success) {
            LOG_DEBUG("Could not read `/etc/niminfo`");
            return {};
        }

        boost::smatch type;
        boost::regex expr{"NIM_CONFIGURATION=(master|standalone)"};
        boost::regex_search(exec.output, type, expr);

        return type[1];
    }

    void nim_resolver::resolve(collection& facts) {
        string type = read_niminfo();
        if (type.empty()) {
            return;
        }
        facts.add(fact::nim_type, make_value<string_value>(type, true));
    }
}}};  // namespace facter::facts::aix
