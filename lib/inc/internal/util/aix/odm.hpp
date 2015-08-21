#include <odmi.h>

#include <cstdint>
#include <memory>
#include <string>

namespace facter { namespace util { namespace aix {

    // This is a singleton class that handles initialization and
    // termination of the ODM library. As long as any other class holds a
    // reference to this one, ODM will remain initialized.
    //
    // This class also provides static helpers for interacting with the ODM
    class odm {
    public:
         typedef std::shared_ptr<odm> ptr;
         static ptr get() {
             static std::weak_ptr<odm> self;

             auto result = self.lock();
             if(!result) {
                 result = ptr(new odm);
                 self = result;
             }
             return result;
         }

         odm(const odm&) = delete;
         odm& operator=(const odm&) = delete;

         ~odm() {
             odm_terminate();
         }

         // unlike just about every other error code to string function in the
         // world, odm_err_msg doesn't just return its pointer - it wants a
         // char** argument to put it in. This wraps that ugly API in a more
         // strerror()-like interface for ease of use.
         static const char* error_string() {
             static char* msg;
             int result = odm_err_msg(odmerrno, &msg);
             if (result < 0) {
                 return "failed to retrieve ODM error message";
             } else {
                 return msg;
             }
         }



    private:
         odm() {
             if (odm_initialize() < 0) {
                 throw std::runtime_error(odm::error_string());
             }
         }
    };

    // This templatized class represents an open ODM class (which you
    // should think of like a table in a traditional database).
    //
    // Each class is a singleton, since it is not possible to access a
    // single ODM class concurrently.
    //
    // calling odm_class<T>::get() will actually return a proxy object,
    // rather than the shared_ptr for the singleton directly. This proxy
    // object allows using value semantics instead of pointer
    // semantics. This is mostly for the sake of range-based for loops,
    // since otherwise a dereference would be necessary.
    //
    // The proxy object implements the basic begin/end iterator interface,
    // as well as a .query() method, which returns a special odm-query
    // object (tied to the odm_class<T> singleton) which also implements
    // the begin/end iterator interface.
    template <typename T>
    class odm_class : public std::enable_shared_from_this<odm_class<T>> {
    public:
        typedef std::shared_ptr<odm_class<T>> ptr;

        // iterators maintain a reference to the odm_class<T> that spawned
        // them. As long as they are valid (not == end()), they will keep
        // the odm_class<T> locked, which prevents a new iteration on the
        // class.  When an iterator is incremented to end() or is
        // destroyed, it will unlock the class.
        class iterator {
        public:
             bool operator != (const iterator& rhs) {
                 return data != rhs.data && owner != rhs.owner;
             }

             iterator& operator++() {
                 if(!data || !owner) {
                     return *this;
                 }
                 free(data);
                 data = static_cast<T*>(odm_get_next(owner->klass, nullptr));
                 // If data == nullptr, we have reached the end of this query
                 if(!data) {
                     owner->locked = false;
                     owner = ptr(nullptr);
                 }
                 if ((intptr_t)data < 0) {
                     throw std::runtime_error(odm::error_string());
                 }
                 return *this;
             }

             const T& operator*() const{
                 return *data;
             }

             ~iterator() {
                 if(data) {
                     free(data);
                 }
             }

        protected:  // Constructor is protected so iterators must come from an odm_class<T> or its associated query_proxy
             iterator(T* d, ptr o) : data(d), owner(o) {
                 if(data) {
                     if(!owner)
                          throw std::logic_error("Tried to construct an iterator with valid data but no owner. Naughty naughty.");
                     owner->locked = true;
                 } else {
                     // In theory nobody should be constructing us with
                     // null data and valid owner, but why take the risk?
                     owner = ptr(nullptr);
                 }
             }

        private:
             T *data;
             ptr owner;

             friend class odm_class::query_proxy;
             friend class odm_class;
        };
        friend class iterator;  // iterator is our friend so it can lock/unlock us.

        // The query proxy represents an active or upcoming query on an
        // ODM class. The presence of a query object does NOT immediately
        // lock the ODM class. Instead, it is the creation of the first
        // iterator that causes locking to happen (at the same time that
        // we actually start interacting with the ODM)
        class query_proxy {
        public:
             iterator begin() {
                 if (owner->locked) {
                     throw std::logic_error("Cannot iterate over the same ODM class concurrently");
                 }
                 auto data = static_cast<T*>(odm_get_first(owner->klass, const_cast<char*>(query.c_str()), nullptr));
                 if ((intptr_t)data < 0) {
                     throw std::runtime_error(odm::error_string());
                 }
                 return iterator(data, owner);
             }

             iterator end() {
                 return iterator(nullptr, nullptr);
             }

        protected:
             query_proxy(std::string q, ptr o) : query(q), owner(o) {}

        private:
             std::string query;
             ptr owner;

             friend class odm_class;
        };
        friend class query_proxy;  // query proxy needs to know if we're locked so it can begin() properly.

        // The proxy class just provides for nicer syntax around
        // range-based for loops. Instead of for (auto& i : *my_odm) you
        // can do for (auto& i : my_odm)
        //
        // It implements begin, end, and iterator. The actual shared ptr
        // to the odm_class<T> is private, so this class is actually the
        // entirety of the API that we provide.
        class proxy {
        public:
             iterator begin() {
                 return self->begin();
             }

             iterator end() {
                 return self->end();
             }

             query_proxy query(std::string q) {
                 return self->query(std::move(q));
             }

        protected:
             proxy(ptr self) : self(self) {}

        private:
             ptr self;

             friend class odm_class;
        };
        friend class proxy;  // proxy needs to, well, proxy to us.

        // Returns a proxy to the odm class named "name"
        //
        // The type passed as <T> and the name will typically be the same,
        // since the AIX tooling that generates ODM interface files
        // creates such things. AFAIK this isn't an absolute requirement
        // of the system, thoug.
        static proxy open(std::string name) {
            static std::weak_ptr<odm_class<T>> self;

            auto result = self.lock();
            if(!result) {
                result = ptr(new odm_class<T>(name));
                self = result;
            }
            return proxy { result };
        }

        odm_class() = delete;
        odm_class(const odm_class&) = delete;
        odm& operator=(const odm&) = delete;

        ~odm_class() {
            odm_close_class(klass);
        }

    protected:
        query_proxy query(std::string q) {
            return query_proxy(q, this->shared_from_this());
        };

        iterator begin() {
            return query("").begin();
        }

        iterator end() {
            return iterator(nullptr, nullptr);
        }

    private:
        odm_class(std::string name) {
            the_odm = odm::get();
            klass = odm_mount_class(const_cast<char*>(name.c_str()));
            if (reinterpret_cast<intptr_t>(klass) < 0) {
                throw std::runtime_error(odm::error_string());
            }
            klass = odm_open_class_rdonly(klass);
            if (reinterpret_cast<intptr_t>(klass) < 0) {
                throw std::runtime_error(odm::error_string());
            }
        }

    protected:
        CLASS_SYMBOL klass;
        bool locked;

    private:
        odm::ptr the_odm;
    };

}}}  // namespace facter::util::aix
