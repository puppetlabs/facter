#include <internal/util/posix/scoped_addrinfo.hpp>

using namespace std;

namespace facter { namespace util { namespace posix {

    scoped_addrinfo::scoped_addrinfo(string const& hostname) :
        scoped_resource(nullptr, free)
    {
        addrinfo hints;
        memset(&hints, 0, sizeof hints);
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = AI_CANONNAME;

        _result = getaddrinfo(hostname.c_str(), nullptr, &hints, &_resource);
        if (_result != 0) {
            _resource = nullptr;
        }
    }

    scoped_addrinfo::scoped_addrinfo(addrinfo* info) :
        scoped_resource(move(info), free),
        _result(0)
    {
    }

    int scoped_addrinfo::result() const
    {
        return _result;
    }

    void scoped_addrinfo::free(addrinfo* info)
    {
        if (info) {
            ::freeaddrinfo(info);
        }
    }

}}}  // namespace facter::util::posix
