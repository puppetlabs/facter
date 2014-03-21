#ifndef __SCOPED_RESOURCE_HPP__
#define __SCOPED_RESOURCE_HPP__

#include <functional>

namespace cfacter {

/**
 Simple class that is used for the RAII pattern.
 
 Used to scope a resource.  When it goes out of scope, a deleter
 function is called to delete the resource.
*/
template<typename T> struct scoped_resource
{
    /**
     Constructs a scoped_resource.
     
     Takes ownership of the given resource.
     @param resource The resource to scope.
     @param deleter The function to call when the resource goes out of scope.
     */
    scoped_resource(T&& resource, std::function<void(T&)> deleter) :
        _resource(resource),
        _deleter(deleter)
    {
    }

    // Force non-copyable
    scoped_resource(scoped_resource<T> const&) = delete;
    scoped_resource& operator=(scoped_resource<T> const&) = delete;

    // Force non-moveable
    scoped_resource(scoped_resource<T>&&) = delete;
    scoped_resource& operator=(scoped_resource<T>&&) = delete;

    /**
     Destructs a scoped_resource.
     */
    virtual ~scoped_resource()
    {
        _deleter(_resource);
    }

    /**
     Implicitly casts to T&.
     */
    operator T&()
    {
        return _resource;
    }

    /**
     Implicitly casts to T const&.
     */
    operator T const&() const
    {
        return _resource;
    }

private:
    T _resource;
    std::function<void(T&)> _deleter;
};

/**
 Represents a scoped file descriptor.
 
 Automatically closes the file descriptor when it goes out of scope.
*/
struct scoped_descriptor : scoped_resource<int>
{
    scoped_descriptor(int descriptor) :
        scoped_resource(std::move(descriptor), close)
    {
    }

private:
    static void close(int descriptor)
    {
        if (descriptor >= 0) {
            ::close(descriptor);
        }
    }
};

} // namespace cfacter

#endif
