/**
 * @file
 * Declares the base class for scope exit.
 */
#pragma once

#include <functional>
#include "../export.h"

namespace facter { namespace util {

    /**
     * Used to call a function when scope is exited.
    */
    struct LIBFACTER_EXPORT scope_exit
    {
        /**
         * Constructs a scope_exit.
         */
        scope_exit();

        /**
         * Constructs a scope_exit.
         * @param callback The function to call when scope is exited.
         */
        explicit scope_exit(std::function<void()> callback);

        /**
         * Moves the given scope_exit into this scope_exit.
         * @param other The scope_exit to move into this scope_exit.
         */
        scope_exit(scope_exit&& other);

        /**
         * Moves the given scoped_resource into this scoped_resource.
         * @param other The scoped_resource to move into this scoped_resource.
         * @return Returns this scope_exit.
         */
        scope_exit& operator=(scope_exit&& other);

        /**
         * Destructs a scope_exit.
         */
        ~scope_exit();

        /**
         * Invokes the callback.
         * If called, the callback will not be called upon destruction.
         */
        void invoke();

    private:
        explicit scope_exit(scope_exit const&) = delete;
        scope_exit& operator=(scope_exit const&) = delete;
        void* operator new(size_t) = delete;
        void operator delete(void*) = delete;
        void* operator new[](size_t) = delete;
        void operator delete[](void* ptr) = delete;

        std::function<void()> _callback;
    };

}}  // namespace facter::util
