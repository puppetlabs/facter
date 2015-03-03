#include <facter/facts/collection.hpp>
#include <facter/facts/external/json_resolver.hpp>
#include <facter/facts/external/text_resolver.hpp>
#include <facter/facts/external/yaml_resolver.hpp>
#include <facter/facts/external/execution_resolver.hpp>
#include <facter/facts/external/windows/powershell_resolver.hpp>
#include <facter/facts/windows/dmi_resolver.hpp>
#include <facter/facts/windows/identity_resolver.hpp>
#include <facter/facts/windows/kernel_resolver.hpp>
#include <facter/facts/windows/memory_resolver.hpp>
#include <facter/facts/windows/networking_resolver.hpp>
#include <facter/facts/windows/operating_system_resolver.hpp>
#include <facter/facts/windows/processor_resolver.hpp>
#include <facter/facts/windows/timezone_resolver.hpp>
#include <facter/facts/windows/uptime_resolver.hpp>
#include <facter/facts/windows/virtualization_resolver.hpp>
#include <facter/util/environment.hpp>
#include <facter/util/scoped_resource.hpp>
#include <facter/util/windows/system_error.hpp>
#include <facter/util/windows/windows.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <Shlobj.h>

using namespace std;
using namespace facter::util;
using namespace facter::util::windows;
using namespace facter::facts::external;
using namespace boost::filesystem;

namespace facter { namespace facts {

    vector<string> collection::get_external_fact_directories()
    {
        // Get the user data path
        TCHAR szPath[MAX_PATH];
        if (!SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, 0, szPath))) {
            LOG_DEBUG("error finding COMMON_APPDATA: %1%", system_error());
        }
        path p = path(szPath) / "PuppetLabs" / "facter" / "facts.d";
        return vector<string>{p.string()};
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
