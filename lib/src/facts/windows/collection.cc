#include <facter/facts/collection.hpp>
#include <facter/facts/external/json_resolver.hpp>
#include <facter/facts/external/text_resolver.hpp>
#include <facter/facts/external/yaml_resolver.hpp>
#include <facter/facts/external/execution_resolver.hpp>
#include <facter/facts/external/windows/powershell_resolver.hpp>
#include <facter/facts/windows/dmi_resolver.hpp>
#include <facter/facts/windows/kernel_resolver.hpp>
#include <facter/facts/windows/memory_resolver.hpp>
#include <facter/facts/resolvers/operating_system_resolver.hpp>
#include <facter/facts/windows/processor_resolver.hpp>
#include <facter/facts/windows/virtualization_resolver.hpp>
#include <facter/util/environment.hpp>
#include <facter/util/scoped_resource.hpp>
#include <facter/util/windows/scoped_error.hpp>
#include <facter/util/windows/wmi.hpp>
#include <facter/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <windows.h>
#include <Shlobj.h>

using namespace std;
using namespace facter::util;
using namespace facter::facts::external;
using namespace boost::filesystem;

#ifdef LOG_NAMESPACE
  #undef LOG_NAMESPACE
#endif
#define LOG_NAMESPACE "facts.collection"

namespace facter { namespace facts {

    vector<string> collection::get_external_fact_directories()
    {
        // Get the user data path
        TCHAR szPath[MAX_PATH];
        if (!SUCCEEDED(SHGetFolderPath(NULL, CSIDL_COMMON_APPDATA, NULL, 0, szPath))) {
            auto err = GetLastError();
            LOG_DEBUG("error finding COMMON_APPDATA: %1% (%2%)", scoped_error(err), err);
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
        // TODO WINDOWS: Add facts as created.
        add(make_shared<windows::dmi_resolver>());
        add(make_shared<windows::kernel_resolver>());
        add(make_shared<windows::memory_resolver>());
        add(make_shared<resolvers::operating_system_resolver>());
        add(make_shared<windows::processor_resolver>());
        add(make_shared<windows::virtualization_resolver>());

        // Release COM resources, we're done making requests for now.
        facter::util::windows::wmi::release();
    }

}}  // namespace facter::facts
