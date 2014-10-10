#include <facter/util/windows/wmi.hpp>
#include <facter/execution/execution.hpp>
#include <boost/algorithm/string/join.hpp>

using namespace std;
using namespace facter::execution;

namespace facter { namespace util { namespace windows { namespace wmi {

    // query is implemented as a straight exec of wmic for simplicity.
    // The COM support in MinGW is deficient, so calling WMI from C++ requires
    // some convoluted setup to link the correct libraries. This should only
    // introduce a little additional overhead, as setting up the COM connection
    // is also not a simple process.
    imap query(string const& group, vector<string> const& keys)
    {
        imap vals;

        each_line("wmic",
            {"wmic", group, "GET", boost::join(keys, ","), "/format:textvaluelist.xsl"},
            [&](string &line) {
                auto eq = line.find('=');
                if (eq != string::npos) {
                    vals.emplace(line.substr(0, eq), line.substr(eq+1));
                }
                return true;
            }, {execution_options::defaults, execution_options::redirect_stderr});

        return vals;
    }

}}}}  // namespace facter::util::windows::wmi
