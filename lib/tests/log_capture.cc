#include "log_capture.hpp"
#include <boost/nowide/iostream.hpp>

using namespace std;
using namespace facter::logging;

namespace facter { namespace testing {

    log_capture::log_capture(facter::logging::level level)
    {
        // Setup logging for capturing
        setup_logging(_stream);
        set_level(level);
    }

    log_capture::~log_capture()
    {
        // Cleanup
        setup_logging(boost::nowide::cout);
        set_level(level::none);
        clear_logged_errors();
    }

    string log_capture::result() const
    {
        return _stream.str();
    }

}}  // namespace facter::testing
