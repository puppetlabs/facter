/**
 * @file
 * Declares an iterator interface for examining the AIX object data manager
 */

#include <odmi.h>

#include <cstdint>
#include <memory>
#include <string>
#include <utility>

namespace facter { namespace util { namespace aix {

    /**
     * Singleton representing the ODM subsystem.
     * The ODM subsystem needs to be explicitly initialized and terminated when
     * it is used. This wraps that initialization/cleanup such that ODM is
     * initialized when it is first used, and cleaned up when all consumers
     * have released their references to it.
     *
     * some helper methods for interacting with the ODM are also defined here,
     * since we can't have a `namespace odm` here.
     */
    class odm {
    public:
         /// shared_ptr to the odm reference
         using ptr = std::shared_ptr<odm>;

         /**
          * Grab a reference to the ODM subsystem to keep it open.
          * If no references currently exist, this will initialize the ODM
          * subsystem.
          * @return 
          */
         static ptr open() {
             static std::weak_ptr<odm> self;

             auto result = self.lock();
             if (!result) {
                 result = ptr(new odm);
                 self = result;
             }
             return result;
         }

         /// deleted copy constructor
         odm(const odm&) = delete;

         /// deleted assignment operator
         /// @return nothing
         odm& operator=(const odm&) = delete;

         /**
          * Clean up the odm library when there are no more users
          */
         ~odm() {
             odm_terminate();
         }

         /**
          * Get the error string for an ODM error state.
          * @return an error string owned by the ODM subsystem
          */
         static const char* error_string() {
             char* msg;
             int result = odm_err_msg(odmerrno, &msg);
             if (result < 0) {
                 return "failed to retrieve ODM error message";
             } else {
                 return msg;
             }
         }

    private:
         /**
          * Initialize the ODM library
          */
         odm() {
             if (odm_initialize() < 0) {
                 throw std::runtime_error(odm::error_string());
             }
         }
    };

    /**
     * This represents an ODM class as an iterable thing.  An ODM
     * class can be throught of as a table in a typical database.
     * Each templatized version of this has a singleton instance,
     * which represents a process' handle to that table. Each process
     * can open a single ODM class only once, and concurrent
     * operations are not supported.
     *
     * @tparam T the struct that is stored in the ODM class.
     */
    template <typename T>
    class odm_class : public std::enable_shared_from_this<odm_class<T>> {
    public:
        /// shared_ptr to an odm_class
        using ptr = std::shared_ptr<odm_class<T>>;

        /**
         * Implements the standard C++ iterator interface for an
         * odm_class. Iterators can be incremented and compared for
         * inequality. This is the minimum to make range-based for
         * loops work.
         *
         * Additional members may need to be added to make other
         * algorithms play nice.
         */
        class iterator {
        public:
             /**
              * inequality comparison.
              * @param rhs the other iterator to compare to
              * @return true if the iterators are not equal
              */
             bool operator != (const iterator& rhs) {
                 return _data != rhs._data && _owner != rhs._owner;
             }

             /**
              * pre-increment operator. This invalidates any
              * references held to the current data of this iterator.
              * @return the new value of the iterator
              */
             iterator& operator++() {
                 if (!_data || !_owner) {
                     return *this;
                 }
                 free(_data);
                 _data = static_cast<T*>(odm_get_next(_owner->_class, nullptr));
                 // If data == nullptr, we have reached the end of this query
                 if (!_data) {
                     _owner->_locked = false;
                     _owner = ptr(nullptr);
                 }
                 if ((intptr_t)_data < 0) {
                     throw std::runtime_error(odm::error_string());
                 }
                 return *this;
             }

             /**
              * dereference operator
              * @return a reference to the held ODM data structure
              */
             const T& operator*() const{
                 return *_data;
             }

             /**
              * Destructor. Frees any held ODM data.
              */
             ~iterator() {
                 if (_data) {
                     free(_data);
                 }
             }

        protected:  // Constructor is protected so iterators must come from an odm_class<T> or its associated query_proxy
             /**
              * Construct an iterator from an odm_class ptr and the first ODM data pointer
              * @param data the ODM data we point to
              * @param owner the odm_class object that owns this iterator
              */
             iterator(T* data, ptr owner) : _data(data), _owner(owner) {
                 if (_data) {
                     if (!_owner) {
                          throw std::logic_error("Tried to construct an iterator with valid data but no owner. Naughty naughty.");
                     }
                     _owner->_locked = true;
                 } else {
                     // In theory nobody should be constructing us with
                     // null data and valid owner, but why take the risk?
                     _owner = ptr(nullptr);
                 }
             }

        private:
             T *_data;
             ptr _owner;

             friend class odm_class::query_proxy;
             friend class odm_class;
        };
        friend class iterator;  // iterator is our friend so it can lock/unlock us.

        /**
         * A query_proxy instance represents a query of an ODM
         * class. The proxy has begin and end methods to allow it to
         * be used in context of a range-based for loop or other
         * algorithm.
         */
        class query_proxy {
        public:
             /**
              * Begin the actual ODM query. This locks the odm_class until all valid iterators from this query are destroyed.
              * @return first iterator of the query
              */
             iterator begin() {
                 if (_owner->_locked) {
                     throw std::logic_error("Cannot iterate over the same ODM class concurrently");
                 }
                 auto data = static_cast<T*>(odm_get_first(_owner->_class, const_cast<char*>(_query.c_str()), nullptr));
                 if ((intptr_t)data < 0) {
                     throw std::runtime_error(odm::error_string());
                 }
                 return iterator(data, _owner);
             }

             /// @return an end iterator
             iterator end() {
                 return iterator(nullptr, nullptr);
             }

        protected:
             /**
              * Construct a query_proxy for an odm_class query
              * @param query the query string
              * @param owner the odm_class that owns this query
              */
             template <typename Arg>
             query_proxy(Arg&& query, ptr owner) : _query(std::forward<Arg>(query)), _owner(owner) {}

        private:
             std::string _query;
             ptr _owner;

             friend class odm_class;
        };
        friend class query_proxy;  // query proxy needs to know if we're locked so it can begin() properly.

        /**
         * This class exists purely to allow nicer syntax when
         * iterating over an odm_class. Using the proxy, it's possible
         * to use `.begin()` and `.end()`, isntead of `->begin()`.
         */
        class proxy {
        public:
             /**
              * Begin iterating over the entire odm_class. This could
              * potentially be MANY values, so use wisely. You
              * probably want query(). This will lock the odm_class
              * until iteration is complete or all valid iterators are
              * destructed.
              * @return an iterator
              */
             iterator begin() {
                 return _self->begin();
             }

             /**
              * Get the end iterator. All end iterators are identical
              * @return the end iterator
              */
             iterator end() {
                 return _self->end();
             }

             /**
              * Begin a query. This does not look the odm_class until
              * query_proxy::begin() is called.
              * @param query the query string
              * @return a query_proxy representing this query
              */
             template <typename Arg>
             query_proxy query(Arg&& query) {
                 return _self->query(std::forward<Arg>(query));
             }

        protected:
             /**
              * Construct a proxy for an odm_class
              * @param self The odm_class that we proxy for
              */
             proxy(ptr self) : _self(self) {}

        private:
             ptr _self;

             friend class odm_class;
        };
        friend class proxy;  // proxy needs to, well, proxy to us.

        /**
         * Get a reference to an odm_class named "name". This will
         * open the class if it is not yet open. The class will be
         * closed when all existing references are released.
         * @param name The name of the ODM class. Usually the string form of T
         * @return an odm_class::proxy object that represents the requested class
         */
        static proxy open(std::string name) {
            static std::weak_ptr<odm_class<T>> self;

            auto result = self.lock();
            if (!result) {
                result = ptr(new odm_class<T>(name));
                self = result;
            }
            return proxy { result };
        }

        /// deleted default constructor
        odm_class() = delete;

        /// deleted copy constructor
        odm_class(const odm_class&) = delete;

        /// deleted assignment operator
        /// @return nothing
        odm& operator=(const odm&) = delete;

        /**
         * Releases an ODM class when there are no more users of it.
         */
        ~odm_class() {
            odm_close_class(_class);
        }

    protected:
        /**
         * @see proxy::query
         * @param query the query string
         * @return a query_proxy representing the provided query
         */
        template <typename Arg>
        query_proxy query(Arg&& query) {
            return query_proxy(std::forward<Arg>(query), this->shared_from_this());
        }

        /**
         * @see proxy::begin
         * @return an iterator
         */
        iterator begin() {
            return query("").begin();
        }

        /**
         * @see proxy::end
         * @return the end/invalid iterator
         */
        iterator end() {
            return iterator(nullptr, nullptr);
        }

    private:
        odm_class(std::string name) : _locked(false) {
            _the_odm = odm::open();
            _class = odm_mount_class(const_cast<char*>(name.c_str()));
            if (reinterpret_cast<intptr_t>(_class) < 0) {
                throw std::runtime_error(odm::error_string());
            }
            _class = odm_open_class_rdonly(_class);
            if (reinterpret_cast<intptr_t>(_class) < 0) {
                throw std::runtime_error(odm::error_string());
            }
        }

    protected:
        /// The ODM class that we are wrapping
        CLASS_SYMBOL _class;

        /// whether we are currently locked for iteration
        bool _locked;

    private:
        odm::ptr _the_odm;
    };

}}}  // namespace facter::util::aix
