#include <internal/util/posix/utmpx_file.hpp>
#include <leatherman/locale/locale.hpp>
#include <leatherman/logging/logging.hpp>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;

namespace facter { namespace util { namespace posix {

    bool utmpx_file::instance_exists = false;

    utmpx_file::utmpx_file() {
      if (utmpx_file::instance_exists) {
        throw logic_error(_("only one utmpx_file instance can exist at a time!"));
      }

      utmpx_file::instance_exists = true;
      reset();
    }

    utmpx_file::~utmpx_file() {
        endutxent();
        utmpx_file::instance_exists = false;
    }

    const utmpx* utmpx_file::query(utmpx const& query) const {
        LOG_DEBUG(_("Reading the utmpx file ..."));
        return getutxid(&query);
    }

    void utmpx_file::reset() const {
        setutxent();
    }
}}}  // namespace facter::util::posix
