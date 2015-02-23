#include <facter/util/windows/wmi.hpp>
#include <leatherman/logging/logging.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string/join.hpp>
#include <boost/algorithm/string/trim.hpp>
#include <boost/range/iterator_range.hpp>
#include <boost/nowide/convert.hpp>

#define _WIN32_DCOM
#include <comdef.h>
#include <wbemidl.h>

using namespace std;
using namespace facter::execution;

namespace facter { namespace util { namespace windows {

    wmi_exception::wmi_exception(string const& message) :
        runtime_error(message)
    {
    }

    string format_hresult(char const* s, HRESULT hres)
    {
        return str(boost::format("%1% (%2%)") % s % boost::io::group(hex, showbase, hres));
    }

    // GUID taken from a Windows installation and unaccepted change to MinGW-w64. The MinGW-w64 library
    // doesn't define it, but obscures the Windows Platform SDK version of wbemuuid.lib.
    constexpr static CLSID MyCLSID_WbemLocator = {0x4590f811, 0x1d3a, 0x11d0, 0x89, 0x1f, 0x00, 0xaa, 0x00, 0x4b, 0x2e, 0x24};

    wmi::wmi()
    {
        LOG_DEBUG("initializing WMI");
        auto hres = CoInitializeEx(0, COINIT_MULTITHREADED);
        if (FAILED(hres)) {
            if (hres == RPC_E_CHANGED_MODE) {
                LOG_DEBUG("using prior COM concurrency model");
            } else {
                throw wmi_exception(format_hresult("failed to initialize COM library", hres));
            }
        } else {
            _coInit = scoped_resource<bool>(true, [](bool b) { CoUninitialize(); });
        }

        IWbemLocator *pLoc;
        hres = CoCreateInstance(MyCLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER, IID_IWbemLocator,
            reinterpret_cast<LPVOID *>(&pLoc));
        if (FAILED(hres)) {
            throw wmi_exception(format_hresult("failed to create IWbemLocator object", hres));
        }
        _pLoc = scoped_resource<IWbemLocator *>(move(pLoc),
            [](IWbemLocator *loc) { if (loc) loc->Release(); });

        IWbemServices *pSvc;
        hres = (*_pLoc).ConnectServer(_bstr_t(L"ROOT\\CIMV2"), nullptr, nullptr, nullptr, 0, nullptr, nullptr, &pSvc);
        if (FAILED(hres)) {
            throw wmi_exception(format_hresult("could not connect to WMI server", hres));
        }
        _pSvc = scoped_resource<IWbemServices *>(move(pSvc),
            [](IWbemServices *svc) { if (svc) svc->Release(); });

        hres = CoSetProxyBlanket(_pSvc, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL,
            RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE);
        if (FAILED(hres)) {
            throw wmi_exception(format_hresult("could not set proxy blanket", hres));
        }
    }

    static void wmi_add_result(wmi::imap &vals, string const& group, string const& s, VARIANT *vtProp)
    {
        if (V_VT(vtProp) == (VT_ARRAY | VT_BSTR)) {
            // It's an array of elements; serialize the array as elements with the same key in the imap.
            // To keep this simple, ignore multi-dimensional arrays.
            SAFEARRAY *arr = V_ARRAY(vtProp);
            if (arr->cDims != 1) {
                LOG_DEBUG("ignoring %1%-dimensional array in query %2%.%3%", arr->cDims, group, s);
                return;
            }

            BSTR *pbstr;
            if (FAILED(SafeArrayAccessData(arr, reinterpret_cast<void **>(&pbstr)))) {
                return;
            }

            for (auto i = 0u; i < arr->rgsabound[0].cElements; ++i) {
                vals.emplace(s, boost::trim_copy(boost::nowide::narrow(pbstr[i])));
            }
            SafeArrayUnaccessData(arr);
        } else if (FAILED(VariantChangeType(vtProp, vtProp, 0, VT_BSTR)) || V_VT(vtProp) != VT_BSTR) {
            // Uninitialized (null) values can just be ignored. Any others get reported.
            if (V_VT(vtProp) != VT_NULL) {
                LOG_DEBUG("WMI query %1%.%2% result could not be converted from type %3% to a string", group, s, V_VT(vtProp));
            }
        } else {
            vals.emplace(s, boost::trim_copy(boost::nowide::narrow(V_BSTR(vtProp))));
        }
    }

    wmi::imaps wmi::query(string const& group, vector<string> const& keys, string const& extended) const
    {
        IEnumWbemClassObject *_pEnum = NULL;
        string qry = "SELECT " + boost::join(keys, ",") + " FROM " + group;
        if (!extended.empty()) {
            qry += " " + extended;
        }

        auto hres = (*_pSvc).ExecQuery(_bstr_t(L"WQL"), _bstr_t(boost::nowide::widen(qry).c_str()),
            WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY, NULL, &_pEnum);
        if (FAILED(hres)) {
            LOG_DEBUG("query %1% failed", qry);
            return {};
        }
        scoped_resource<IEnumWbemClassObject *> pEnum(move(_pEnum),
            [](IEnumWbemClassObject *rsc) { if (rsc) rsc->Release(); });

        imaps array_of_vals;

        IWbemClassObject *pclsObjs[256];
        ULONG uReturn = 0;
        while (pEnum) {
            auto hr = (*pEnum).Next(WBEM_INFINITE, 256, pclsObjs, &uReturn);
            if (FAILED(hr) || 0 == uReturn) {
                break;
            }

            for (auto pclsObj : boost::make_iterator_range(pclsObjs, pclsObjs+uReturn)) {
                imap vals;
                for (auto &s : keys) {
                    VARIANT vtProp;
                    CIMTYPE vtType;
                    hr = pclsObj->Get(_bstr_t(boost::nowide::widen(s).c_str()), 0, &vtProp, &vtType, 0);
                    if (FAILED(hr)) {
                        LOG_DEBUG("query %1%.%2% could not be found", group, s);
                        break;
                    }

                    wmi_add_result(vals, group, s, &vtProp);
                    VariantClear(&vtProp);
                }
                pclsObj->Release();
                array_of_vals.emplace_back(move(vals));
            }
        }

        return array_of_vals;
    }

    string const& wmi::get(wmi::imap const& kvmap, string const& key)
    {
        static const string empty = {};
        auto valIt = kvmap.find(key);
        if (valIt == kvmap.end()) {
            return empty;
        } else {
            if (kvmap.count(key) > 1) {
                LOG_DEBUG("only single value requested from array for key %1%", key);
            }
            return valIt->second;
        }
    }

    wmi::kv_range wmi::get_range(wmi::imap const& kvmap, string const& key)
    {
        return kv_range(kvmap.equal_range(key));
    }

    string const& wmi::get(wmi::imaps const& kvmaps, string const& key)
    {
        if (kvmaps.size() > 0) {
            if (kvmaps.size() > 1) {
                LOG_DEBUG("only single entry requested from array of entries for key %1%", key);
            }
            return get(kvmaps[0], key);
        } else {
            throw wmi_exception("unable to get from empty array of objects");
        }
    }

    wmi::kv_range wmi::get_range(wmi::imaps const& kvmaps, string const& key)
    {
        if (kvmaps.size() > 0) {
            if (kvmaps.size() > 1) {
                LOG_DEBUG("only single entry requested from array of entries for key %1%", key);
            }
            return get_range(kvmaps[0], key);
        } else {
            throw wmi_exception("unable to get_range from empty array of objects");
        }
    }

}}}  // namespace facter::util::windows
