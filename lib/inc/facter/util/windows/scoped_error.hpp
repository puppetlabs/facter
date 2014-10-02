#pragma once

#include "../scoped_resource.hpp"
#include <windows.h>

namespace facter { namespace util {
    /**
     * This is an RAII wrapper for handling error messages on Windows.
     * It provides accessors to retrieve the error code and string.
     * The error message related to the specified error code is retrieved on construction.
     */
    struct scoped_error : scoped_resource<TCHAR *>
    {
        /**
         * Constructs a scoped_error from the last error.
         */
        explicit scoped_error();

        /**
         * Constructs a scoped_error from the specified error code.
         * @param err The error code.
         */
        explicit scoped_error(DWORD err);

        /**
         * Return the error code for the scoped_error.
         * @return Returns the error code.
         */
        DWORD error() const { return _err; }

     private:
        DWORD _err;
    };
}}  // namespace facter::util
