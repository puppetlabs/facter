#include <facts/posix/kernel_resolver.hpp>
#include <facts/fact_map.hpp>
#include <facts/string_value.hpp>
#include <util/string.hpp>

using namespace std;
using namespace cfacter::util;

namespace cfacter { namespace facts { namespace posix {

    void kernel_resolver::resolve_facts(fact_map& facts)
    {
        utsname name;
        memset(&name, 0, sizeof(name));
        if (uname(&name) != 0) {
            return;
        }
        // Resolve all kernel-related facts
        resolve_kernel(facts, name);
        resolve_kernel_release(facts, name);
        resolve_kernel_version(facts);
        resolve_kernel_major_version(facts);
    }

    void kernel_resolver::resolve_kernel(fact_map& facts, utsname const& name)
    {
        string value = name.sysname;
        if (value.empty()) {
            return;
        }
        facts.add(kernel_name, make_value<string_value>(std::move(value)));
    }

    void kernel_resolver::resolve_kernel_release(fact_map& facts, utsname const& name)
    {
        string value = name.release;
        if (value.empty()) {
            return;
        }
        facts.add(kernel_release_name, make_value<string_value>(std::move(value)));
    }

    void kernel_resolver::resolve_kernel_version(fact_map& facts)
    {
        auto version = facts.get<string_value>(kernel_release_name);
        if (!version) {
            return;
        }
        // Use everything up until the first - character in the kernel release fact
        string value = version->value();
        auto pos = value.find('-');
        if (pos != string::npos) {
            value = value.substr(0, pos);
        }
        facts.add(kernel_version_name, make_value<string_value>(std::move(value)));
    }

    void kernel_resolver::resolve_kernel_major_version(fact_map& facts)
    {
        auto version = facts.get<string_value>(kernel_release_name);
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
        facts.add(kernel_maj_release_name, make_value<string_value>(std::move(value)));
    }

}}}  // namespace cfacter::facts::posix
