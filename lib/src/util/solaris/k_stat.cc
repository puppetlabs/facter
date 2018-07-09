#include <internal/util/solaris/k_stat.hpp>
#include <sys/kstat.h>
#include <cstring>
#include <leatherman/locale/locale.hpp>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;

namespace facter { namespace util { namespace solaris {
    k_stat::k_stat() {
        if (ctrl == nullptr) {
            throw kstat_exception(_("kstat_open failed"));
        }
    }

    vector<k_stat_entry> k_stat::operator[](string const& module)
    {
        return lookup(module, -1, {});
    }

    vector<k_stat_entry> k_stat::operator[](pair<string, int> const& entry)
    {
        return lookup(entry.first, entry.second, {});
    }

    vector<k_stat_entry> k_stat::operator[](pair<string, string> const& entry)
    {
        return lookup(entry.first, -1, entry.second);
    }

// I believe precedence to be sufficiently obvious in this function,
// but this is a worthwhile diagnostic in most cases. We disable it
// here, instead of globally.
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wparentheses"
    vector<k_stat_entry> k_stat::lookup(string const& module, int instance, string const& name)
    {
        kstat_t* kp = static_cast<kstat_ctl_t*>(ctrl)->kc_chain;
        vector<k_stat_entry> arr;
        do {
            if (!module.empty() && module != kp->ks_module ||
                !name.empty() && name != kp->ks_name ||
                instance != -1 && instance != kp->ks_instance) {
                continue;
            }
            while (kstat_read(ctrl, kp, 0) == -1) {
                if (errno == EAGAIN) {
                    continue;
                } else {
                    throw kstat_exception(_("kstat_read failed: {1} ({2})",
                                            string(strerror(errno)),
                                            to_string(errno)));
                }
            }
            arr.push_back(k_stat_entry(kp));
        } while (kp = kp->ks_next);

        return arr;
    }
#pragma GCC diagnostic pop

    k_stat_entry::k_stat_entry(kstat_t* kp) :
        k_stat(kp)
    {
    }

    int k_stat_entry::instance()
    {
        return k_stat->ks_instance;
    }

    string k_stat_entry::klass()
    {
        return k_stat->ks_class;
    }

    string k_stat_entry::module()
    {
        return k_stat->ks_module;
    }

    string k_stat_entry::name()
    {
        return k_stat->ks_name;
    }

    kstat_named_t* k_stat_entry::lookup(const string& attrib) const
    {
        kstat_named_t* knp = reinterpret_cast<kstat_named_t*>(kstat_data_lookup(k_stat, const_cast<char*>(attrib.c_str())));
        if (knp == nullptr) {
            throw kstat_exception(_("kstat_data_lookup failed for {1}", attrib));
        }
        return knp;
    }

     kstat_named_t* k_stat_entry::lookup(int datatype, const string& attrib) const
    {
        kstat_named_t* knp = reinterpret_cast<kstat_named_t*>(kstat_data_lookup(k_stat, const_cast<char*>(attrib.c_str())));
        if (knp == nullptr) {
            throw kstat_exception(_("kstat_data_lookup failed for {1}", attrib));
        }
        if (knp->data_type != datatype) {
            throw kstat_exception(_("invalid datatype {1} {2}", attrib, to_string(knp->data_type)));
        }
        return knp;
    }

    template<>
    ulong_t k_stat_entry::value(const std::string& attrib) const
    {
        return lookup(KSTAT_DATA_ULONG, attrib)->value.ul;
    }

    template<>
    long k_stat_entry::value(const std::string& attrib) const
    {
        return lookup(KSTAT_DATA_LONG, attrib)->value.l;
    }

    template<>
    int32_t k_stat_entry::value(const std::string& attrib) const
    {
        return lookup(KSTAT_DATA_INT32, attrib)->value.i32;
    }

    template<>
    uint32_t k_stat_entry::value(const std::string& attrib) const
    {
        return lookup(KSTAT_DATA_UINT32, attrib)->value.ui32;
    }

    template<>
    int64_t k_stat_entry::value(const std::string& attrib) const
    {
        return lookup(KSTAT_DATA_INT64, attrib)->value.i64;
    }

    template<>
    uint64_t k_stat_entry::value(const std::string& attrib) const
    {
        return lookup(KSTAT_DATA_UINT64, attrib)->value.ui64;
    }

    template<>
    std::string k_stat_entry::value(const std::string& attrib) const
    {
        auto res = lookup(attrib);
        if (res->data_type == KSTAT_DATA_STRING) {
            return res->value.str.addr.ptr;
        } else if (res->data_type == KSTAT_DATA_CHAR) {
            return string(res->value.c);
        }
        throw kstat_exception(_("invalid datatype {1} {2}", attrib, to_string(res->data_type)));
    }
}}}  // namespace facter::util::solaris
