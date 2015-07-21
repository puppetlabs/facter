#include <internal/facts/resolvers/xen_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/fact.hpp>
#include <facter/facts/vm.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/regex.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;
using namespace facter::facts;
using namespace leatherman::execution;
using namespace leatherman::util;

namespace facter { namespace facts { namespace resolvers {

    xen_resolver::xen_resolver() :
        resolver(
            "Xen",
            {
                fact::xen,
                fact::xendomains
            })
    {
    }

    void xen_resolver::resolve(collection& facts)
    {
        // Confine to fact virtual == xen0
        auto virt = facts.get<string_value>(fact::virtualization);
        if (!virt || virt->value() != vm::xen_privileged) {
            return;
        }

        auto data = collect_data(facts);

        if (!data.domains.empty()) {
            auto xendomains = boost::algorithm::join(data.domains, ",");
            facts.add(fact::xendomains, make_value<string_value>(move(xendomains), true));
        }

        auto domains = make_value<array_value>();
        for (auto& domain : data.domains) {
            domains->add(make_value<string_value>(move(domain)));
        }

        auto xen = make_value<map_value>();
        if (!domains->empty()) {
            xen->add("domains", move(domains));
        }

        if (!xen->empty()) {
            facts.add(fact::xen, move(xen));
        }
    }

    xen_resolver::data xen_resolver::collect_data(collection& facts)
    {
        data result;

        auto command = xen_command();
        if (!command.empty()) {
            static boost::regex domain_header("^(Name|Domain-0)");
            static boost::regex domain_entry("^([^\\s]*)\\s");
            each_line(command, {"list"}, [&](string& line) {
                string domain;
                if (!boost::regex_match(line, domain_header) && re_search(line, domain_entry, &domain)) {
                    result.domains.emplace_back(move(domain));
                }
                return true;
            });
        }

        return result;
    }

}}}  // namespace facter::facts::resolvers
