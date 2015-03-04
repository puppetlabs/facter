#include <internal/util/solaris/scoped_kstat.hpp>

using namespace std;

namespace facter { namespace util { namespace solaris {

    scoped_kstat::scoped_kstat() :
        scoped_resource(nullptr, close)
    {
        _resource = kstat_open();
    }

    scoped_kstat::scoped_kstat(kstat_ctl* ctrl) :
        scoped_resource(move(ctrl), free)
    {
    }

    void scoped_kstat::close(kstat_ctl* ctrl)
    {
        if (ctrl) {
            ::kstat_close(ctrl);
        }
    }

    kstat_exception::kstat_exception(std::string const& message) :
        runtime_error(message)
    {
    }

}}}  // namespace facter::util::solaris
