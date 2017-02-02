/**
 * @file
 * Declares an iterator interface for examining AIX mountpoints
 */

#include <leatherman/logging/logging.hpp>

// AIX doesn't properly wrap these function declarations as C-style
extern "C" {
#include <sys/vmount.h>
}

#include <cstdint>
#include <vector>

namespace facter { namespace util { namespace aix {

    /**
     * This wraps the AIX mntctl(MCTL_QUERY, ...) function in an
     * iterator interface. Each item is a mountctl struct.
     */
    class mountctl {
    public:
        /**
         * Implements the standard C++ iterator interface for mounted
         * filesystems. Iterators can be incremented and compared for
         * inequality. This is the minimum to make range-based for
         * loops work.
         *
         * Additional members may need to be added to make other
         * algorithms play nice.
         */
        class iterator {
            mountctl* _parent;
            size_t _idx;
            struct vmount* _current;
        protected:
            /**
             * Construct an iterator from a mountctl class and the given
             * vmount object index.
             * @param parent the mountctl instance that this iterator points to
             * @param idx the index into the list of vmount instances
             */
            iterator(mountctl* parent, size_t idx)
                 : _parent(parent), _idx(0) {
                _current = reinterpret_cast<struct vmount*>(_parent->_buffer.data());
                while (_idx < idx) {
                     ++(*this);
                }
            }

        public:
            iterator() = delete;

            /// Defaulted move constructor
            iterator(iterator&&) = default;

            /// Defaulted move assignment
            /// @return myself
            iterator& operator=(iterator&&) = default;

            /**
             * inequality comparison
             * @param rhs the other iterator to compare us to
             * @return true if the iterators are not equal
             */
            bool operator != (const iterator& rhs) {
                return _parent != rhs._parent || _idx != rhs._idx;
            }

            /**
             * pre-increment operator. This moves the iterator to
             * the next position in the list of vmount structs
             * @return A reference to this iterator after it has advanced.
             */
            iterator& operator++() {
                // Only increment if we're not at the end
                // thus, end()++ == end();
                if (_idx != _parent->_count) {
                    uintptr_t pos = reinterpret_cast<uintptr_t>(_current);
                    pos += _current->vmt_length;
                    _current = reinterpret_cast<struct vmount*>(pos);
                    _idx++;
                }
                return *this;
            }

            /**
             * dereference operator
             * @return a reference to the held vmount structure
             */
            const struct vmount& operator*() const {
                return *_current;
            }

            friend class mountctl;
        };
        friend class iterator;  // iterator is our friend so it can access data

        /**
         * Query the mounted filesystems and return an iterable instance
         */
        mountctl() {
            uint32_t buf_sz;
            int result = mntctl(MCTL_QUERY, sizeof(uint32_t), reinterpret_cast<char*>(&buf_sz));
            if (result < 0) {
                throw std::system_error(errno, std::system_category());
            }
            LOG_DEBUG("Required space for mountpoints is {1}", buf_sz);

            _buffer.reserve(buf_sz);
            result = mntctl(MCTL_QUERY, buf_sz, _buffer.data());
            if (result < 0) {
                throw std::system_error(errno, std::system_category());
            }
            _count = result;
            LOG_DEBUG("Got {1} mountpoints", _count);
        }

        /// Start the iteration
        /// @return an iterator that references me. I must outlive this iterator
        iterator begin() {
            return iterator(this, 0);
        }

        /// Retrieve iterator sentinel value
        /// @return an iterator that references me. I must outlive this iterator
        iterator end() {
            return iterator(this, _count);
        }

    protected:
        /// The data returned from mntctl. Used by the iterator
        std::vector<char> _buffer;

        /// The number of elements returned from mntctl
        size_t _count;
    };
}}}  // namespace facter::util::aix
