#include <facts/posix/kernel_resolver.hpp>
#include <facts/fact_map.hpp>
#include <facts/string_value.hpp>
#include <execution/execution.hpp>
#include <util/string.hpp>

using namespace std;
using namespace cfacter::execution;
using namespace cfacter::util;

namespace cfacter { namespace facts { namespace posix {

    void kernel_resolver::resolve_facts(fact_map& facts)
    {
        // Resolve all kernel-related facts
        resolve_kernel(facts);
        resolve_kernel_release(facts);
        resolve_kernel_version(facts);
        resolve_kernel_major_version(facts);
    }

    void kernel_resolver::resolve_kernel(fact_map& facts)
    {
        string value = execute("uname", {"-s"}, { execution_options::trim_output });
        if (value.empty()) {
            return;
        }
        facts.add_fact(fact(kernel_name, make_value<string_value>(std::move(value))));
    }

    void kernel_resolver::resolve_kernel_release(fact_map& facts)
    {
        string value = execute("uname", {"-r"}, { execution_options::trim_output });
        if (value.empty()) {
            return;
        }
        facts.add_fact(fact(kernel_release_name, make_value<string_value>(std::move(value))));
    }

    void kernel_resolver::resolve_kernel_version(fact_map& facts)
    {
        auto version = facts.get_value<string_value>(kernel_release_name);
        if (!version) {
            return;
        }
        // Use everything up until the first - character in the kernel release fact
        string value = version->value();
        auto pos = value.find('-');
        if (pos != string::npos) {
            value = value.substr(0, pos);
        }
        facts.add_fact(fact(kernel_version_name, make_value<string_value>(std::move(value))));
    }

    void kernel_resolver::resolve_kernel_major_version(fact_map& facts)
    {
        auto version = facts.get_value<string_value>(kernel_release_name);
        if (!version) {
            return;
        }

        // Use everything up until the second '.' character in the kernel release fact
        string value = version->value();
        auto pos = value.find('.');
        if (pos != string::npos) {
            pos = value.find('.', pos + 1);
            if (pos != string::npos) {
                value = value.substr(0, pos);
            }
        }
        facts.add_fact(fact(kernel_maj_release_name, make_value<string_value>(std::move(value))));
    }

}}}  // namespace cfacter::facts::posix
