/**
 * @file
 * Declares an interface for querying the contents of the utmpx file
 */
#pragma once

#include <utmpx.h>

namespace facter { namespace util { namespace posix {

    /**
     * Class representing a utmpx file. We create only one instance at a time since
     * the utmpx API calls deal with global state. See https://linux.die.net/man/3/getutxid
     * for the documentation.
    */
    class utmpx_file {
    public:
         /**
          * Constructs a utmpx_file instance. We only do this if no other utmpx_file instance exists,
          * which we can determine by querying the 'instance_exists' static variable. Otherwise,
          * we throw an std::logic_error.
          */
         utmpx_file();

         /// deleted copy constructor
         utmpx_file(const utmpx_file&) = delete;

         /// deleted assignment operator
         /// @return nothing
         utmpx_file& operator=(const utmpx_file&) = delete;

         /**
          * Destroys our utmpx_file instance. Here, we also set `instance_exists` to false so that another
          * utmpx_file instance can be created.
          */
         ~utmpx_file();

         /**
          * Returns a pointer to the utmpx entry corresponding to the passed-in query. Make sure
          * that the calling instance does not go out of scope after invoking this method, otherwise
          * the data in the returned utmpx entry will be garbage. Note that this will move the
          * underlying utmpx file pointer forward, so be sure to call reset() if you want subsequent
          * calls to this routine to always start from the beginning of the utmpx file.
          * @param query the utmpx query. See https://www.systutorials.com/docs/linux/man/5-utmpx/
          * @return pointer to the utmpx entry satisfying the query
          */
         const utmpx* query(utmpx const& query) const;

         /**
          * Resets the utmpx file.
          */
         void reset() const;

    private:
         static bool instance_exists;  // set to true if a utmpx_file instance exists, false otherwise
    };
}}}  // namespace facter::util::posix
