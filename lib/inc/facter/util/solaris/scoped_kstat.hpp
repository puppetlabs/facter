/**
 * @file
 * Declares the scoped kstat resource.
 */
#ifndef FACTER_UTIL_SOLARIS_SCOPED_KSTAT_HPP_
#define FACTER_UTIL_SOLARIS_SCOPED_KSTAT_HPP_

#include "../scoped_resource.hpp"
#include <kstat.h>

namespace facter { namespace util { namespace solaris {

    /**
     * kstat exceptions
     */
    struct kstat_exception : std::runtime_error
    {
        /**
         * Constructs a kstat_exception.
         * @param message The exception message.
         */
        explicit kstat_exception(std::string const& message);
    };


    /**
     * Represents a scoped kstat pointer that automatically is freed when it goes out of scope.
    */
    struct scoped_kstat : scoped_resource<kstat_ctl*>
    {
        /**
         * Default constructor.
         * This constructor will handle calling kstat_open.
         */
        scoped_kstat();

        /**
         * Constructs a scoped_descriptor.
         * @param stat The kstat pointer to free when destroyed
         */
        explicit scoped_kstat(kstat_ctl* ctrl);

     private:
        static void close(kstat_ctl* ctrl);
    };

}}}  // namespace facter::util::solaris

#endif  // FACTER_UTIL_SOLARIS_SCOPED_KSTAT_HPP_
