#ifndef LIB_INC_UTIL_SCOPED_RESOURCE_HPP_
#define LIB_INC_UTIL_SCOPED_RESOURCE_HPP_

#include <functional>

namespace cfacter { namespace util {
    /**
     * Simple class that is used for the RAII pattern.
     * Used to scope a resource.  When it goes out of scope, a deleter
     * function is called to delete the resource.
     * @tparam T The type of resource being scoped.
    */
    template<typename T> struct scoped_resource
    {
        /**
         * Constructs a scoped_resource.
         * Takes ownership of the given resource.
         * @param resource The resource to scope.
         * @param deleter The function to call when the resource goes out of scope.
         */
        scoped_resource(T&& resource, std::function<void(T&)> deleter) :
            _resource(resource),
            _deleter(deleter)
        {
        }

        // Force non-copyable
        explicit scoped_resource(scoped_resource<T> const&) = delete;
        scoped_resource& operator=(scoped_resource<T> const&) = delete;

        // Allow moving
        scoped_resource(scoped_resource<T>&&) = default;
        scoped_resource& operator=(scoped_resource<T>&&) = default;

        /**
         * Destructs a scoped_resource.
         */
        virtual ~scoped_resource()
        {
            release();
        }

        /**
         * Implicitly casts to T&.
         * @return Returns reference-to-T.
         */
        operator T&()
        {
            return _resource;
        }

        /**
         * Implicitly casts to T const&.
         * @return Returns const-reference-to-T.
         */
        operator T const&() const
        {
            return _resource;
        }

        /**
         * Releases the resource before destruction.
         */
        void release()
        {
            if (_deleter) {
                _deleter(_resource);
                _deleter = std::function<void(T&)>();
            }
        }

     private:
        T _resource;
        std::function<void(T&)> _deleter;
    };

}}  // namespace cfacter::util

#endif  // LIB_INC_UTIL_SCOPED_RESOURCE_HPP_
