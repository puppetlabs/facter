#include <facter/logging/logging.hpp>

#include <boost/log/sources/severity_logger.hpp>
#include <boost/log/sources/record_ostream.hpp>
#include <boost/log/attributes/scoped_attribute.hpp>

using namespace std;
namespace src = boost::log::sources;
namespace attrs = boost::log::attributes;

namespace facter { namespace logging {

    string const& colorize(log_level level)
    {
        // Windows doesn't natively support colorization
        static string none = "";
        return none;
    }

    string const& colorize()
    {
        // Windows doesn't natively support colorization
        static string none = "";
        return none;
    }

    void log(const string &logger, log_level level, string const& message)
    {
        src::severity_logger<log_level> slg;
        slg.add_attribute("Namespace", attrs::constant<std::string>(logger));
        BOOST_LOG_SEV(slg, level) << message;
    }

}}  // namespace facter::logging
