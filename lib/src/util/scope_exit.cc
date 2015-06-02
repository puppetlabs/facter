#include <facter/util/scope_exit.hpp>

using namespace std;

namespace facter { namespace util {

    scope_exit::scope_exit()
    {
    }

    scope_exit::scope_exit(function<void()> callback) :
        _callback(callback)
    {
    }

    scope_exit::scope_exit(scope_exit&& other)
    {
        *this = std::move(other);
    }

    scope_exit& scope_exit::operator=(scope_exit&& other)
    {
        _callback = std::move(other._callback);

        // Ensure the callback is in a known "empty" state; we can't rely on default move semantics for that
        other._callback = nullptr;
        return *this;
    }

    scope_exit::~scope_exit()
    {
        invoke();
    }

    void scope_exit::invoke()
    {
        if (_callback) {
            _callback();
            _callback = nullptr;
        }
    }

}}  // namespace facter::util
