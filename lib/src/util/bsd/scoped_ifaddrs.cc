#include <internal/util/bsd/scoped_ifaddrs.hpp>

using namespace std;
using namespace leatherman::util;

namespace facter { namespace util { namespace bsd {

    scoped_ifaddrs::scoped_ifaddrs() :
        scoped_resource(nullptr, free)
    {
        // Get the linked list of interfaces
        if (getifaddrs(&_resource) == -1) {
            _resource = nullptr;
        }
    }

    scoped_ifaddrs::scoped_ifaddrs(ifaddrs* addrs) :
        scoped_resource(move(addrs), free)
    {
    }

    void scoped_ifaddrs::free(ifaddrs* addrs)
    {
        if (addrs) {
            ::freeifaddrs(addrs);
        }
    }

}}}  // namespace facter::util::bsd
