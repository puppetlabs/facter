#include <facter/facts/collection.hpp>
#include <internal/facts/external/json_resolver.hpp>
#include <internal/facts/external/text_resolver.hpp>
#include <internal/facts/external/yaml_resolver.hpp>
#include <internal/facts/external/execution_resolver.hpp>
#include <internal/facts/external/windows/powershell_resolver.hpp>
#include <internal/facts/windows/dmi_resolver.hpp>
#include <internal/facts/windows/identity_resolver.hpp>
#include <internal/facts/windows/kernel_resolver.hpp>
#include <internal/facts/windows/memory_resolver.hpp>
#include <internal/facts/windows/networking_resolver.hpp>
#include <internal/facts/windows/operating_system_resolver.hpp>
#include <internal/facts/windows/processor_resolver.hpp>
#include <internal/facts/windows/timezone_resolver.hpp>
#include <internal/facts/windows/uptime_resolver.hpp>
#include <internal/facts/windows/virtualization_resolver.hpp>
#include <leatherman/util/environment.hpp>
#include <leatherman/windows/system_error.hpp>
#include <leatherman/windows/user.hpp>
#include <leatherman/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <Shlobj.h>

using namespace std;
using namespace leatherman::windows;
using namespace leatherman::util;
using namespace facter::facts::external;
using namespace boost::filesystem;

namespace facter { namespace facts {

    vector<string> collection::get_external_fact_directories() const
    {
        if (user::is_admin()) {
            // Get the common data path
            TCHAR szPath[MAX_PATH];
            if (SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, 0, szPath))) {
                path p = path(szPath) / "PuppetLabs" / "facter" / "facts.d";
                return {p.string()};
            }

            LOG_WARNING("error finding COMMON_APPDATA, external facts unavailable: %1%", system_error());
        } else {
            auto home = user::home_dir();
            if (!home.empty()) {
                path p1 = path(home) / ".puppetlabs" / "opt" / "facter" / "facts.d";
                path p2 = path(home) / ".facter" / "facts.d";
                return {p1.string(), p2.string()};
            }

            LOG_DEBUG("HOME environment variable not set, external facts unavailable");
        }

        return {};
    }

    vector<unique_ptr<external::resolver>> collection::get_external_resolvers()
    {
        vector<unique_ptr<external::resolver>> resolvers;
        resolvers.emplace_back(new text_resolver());
        resolvers.emplace_back(new yaml_resolver());
        resolvers.emplace_back(new json_resolver());

        // The execution resolver is a catch-all for Windows executable types: .bat, .cmd, .com, .exe
        resolvers.emplace_back(new execution_resolver());
        resolvers.emplace_back(new powershell_resolver());
        return resolvers;
    }

    void collection::add_platform_facts()
    {
        add(make_shared<windows::identity_resolver>());
        add(make_shared<windows::kernel_resolver>());
        add(make_shared<windows::memory_resolver>());
        add(make_shared<windows::networking_resolver>());
        add(make_shared<windows::timezone_resolver>());

        try {
            shared_ptr<wmi> shared_wmi = make_shared<wmi>();
            add(make_shared<windows::dmi_resolver>(shared_wmi));
            add(make_shared<windows::operating_system_resolver>(shared_wmi));
            add(make_shared<windows::processor_resolver>(shared_wmi));
            add(make_shared<windows::virtualization_resolver>(shared_wmi));
            add(make_shared<windows::uptime_resolver>(shared_wmi));
        } catch (wmi_exception &e) {
            LOG_ERROR("failed adding platform facts that require WMI: %1%", e.what());
        }
    }

}}  // namespace facter::facts
