#include <facter/util/windows/wmi.hpp>
#include <facter/util/windows/string_conv.hpp>
#include <facter/util/scoped_resource.hpp>
#include <facter/logging/logging.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string/join.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/lock_guard.hpp>

#define _WIN32_DCOM
#include <comdef.h>
#include <wbemidl.h>

using namespace std;
using namespace facter::execution;

#undef LOG_NAMESPACE
#define LOG_NAMESPACE "facter.util.windows.wmi"

namespace facter { namespace util { namespace windows { namespace wmi {

    // GUID taken from a Windows installation and unaccepted change to MinGW-w64. The MinGW-w64 library
    // doesn't define it, but obscures the Windows Platform SDK version of wbemuuid.lib.
    static CLSID MyCLSID_WbemLocator = {0x4590f811, 0x1d3a, 0x11d0, 0x89, 0x1f, 0x00, 0xaa, 0x00, 0x4b, 0x2e, 0x24};

    class WMIQuery {
        WMIQuery()
        {
            auto hres = CoInitializeEx(0, COINIT_MULTITHREADED);
            if (FAILED(hres)) {
                throw runtime_error("failed to initialize COM library");
            }
            _coInit = true;

            hres = CoInitializeSecurity(NULL, -1, NULL, NULL, RPC_C_AUTHN_LEVEL_DEFAULT,
                RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE, NULL);
            if (FAILED(hres)) {
                throw runtime_error("failed to initialize security");
            }

            hres = CoCreateInstance(MyCLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER, IID_IWbemLocator,
                reinterpret_cast<LPVOID *>(&_pLoc));
            if (FAILED(hres)) {
                throw runtime_error("failed to create IWbemLocator object");
            }

            hres = _pLoc->ConnectServer(_bstr_t(L"ROOT\\CIMV2"), nullptr, nullptr, nullptr, 0, nullptr, nullptr, &_pSvc);
            if (FAILED(hres)) {
                throw runtime_error("could not connect to WMI server");
            }

            hres = CoSetProxyBlanket(_pSvc, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL,
                RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE);
            if (FAILED(hres)) {
                throw runtime_error("could not set proxy blanket");
            }
        }

        ~WMIQuery()
        {
            if (_coInit) {
                CoUninitialize();
            }

            if (_pLoc) {
                _pLoc->Release();
            }

            if (_pSvc) {
                _pSvc->Release();
            }
        }

        bool _coInit = false;
        IWbemLocator *_pLoc = nullptr;
        IWbemServices *_pSvc = nullptr;
        static WMIQuery *_instance;
        static boost::mutex _instMutex;

     public:
        imap query(string const& group, vector<string> const& keys) const
        {
            IEnumWbemClassObject *_pEnum = NULL;
            string qry = "SELECT " + boost::join(keys, ",") + " FROM " + group;

            auto hres = _pSvc->ExecQuery(_bstr_t(L"WQL"), _bstr_t(to_utf16(qry).c_str()),
                WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY, NULL, &_pEnum);
            if (FAILED(hres)) {
                LOG_DEBUG("query %1% failed", qry);
                return {};
            }
            scoped_resource<IEnumWbemClassObject *> pEnum(move(_pEnum),
                [](IEnumWbemClassObject *rsc) { if (rsc) rsc->Release(); });

            imap vals;

            IWbemClassObject *pclsObj;
            ULONG uReturn = 0;
            while (pEnum) {
                auto hr = (*pEnum).Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
                if (FAILED(hr) || 0 == uReturn) {
                    break;
                }

                for (auto &s : keys) {
                    VARIANT vtProp;
                    hr = pclsObj->Get(_bstr_t(to_utf16(s).c_str()), 0, &vtProp, 0, 0);
                    if (FAILED(hr)) {
                        break;
                    }
                    vals.emplace(s, to_utf8(vtProp.bstrVal));
                    VariantClear(&vtProp);
                }

                pclsObj->Release();
            }

            return vals;
        }

        static WMIQuery const& get()
        {
            boost::lock_guard<boost::mutex> instLock(_instMutex);
            if (!_instance) {
                _instance = new WMIQuery();
            }
            return *_instance;
        }

        static void release()
        {
            boost::lock_guard<boost::mutex> instLock(_instMutex);
            if (_instance) {
                delete _instance;
                _instance = nullptr;
            }
        }
    };

    WMIQuery *WMIQuery::_instance = nullptr;
    boost::mutex WMIQuery::_instMutex;

    imap query(string const& group, vector<string> const& keys)
    {
        try {
            return WMIQuery::get().query(group, keys);
        } catch (runtime_error &e) {
            LOG_DEBUG(e.what());
            return {};
        }
    }

    void release()
    {
        WMIQuery::release();
    }

}}}}  // namespace facter::util::windows::wmi
