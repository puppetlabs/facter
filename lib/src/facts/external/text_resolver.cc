#include <internal/facts/external/text_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/logging/logging.hpp>
#include <leatherman/locale/locale.hpp>
#include <boost/algorithm/string.hpp>

// Mark string for translation (alias for leatherman::locale::format)
using leatherman::locale::_;

using namespace std;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace external {

    void text_resolver::resolve(collection& facts) const
    {
        LOG_DEBUG("resolving facts from text file \"{1}\".", _path);

        if (!lth_file::each_line(_path, [&facts](string& line) {
            auto pos = line.find('=');
            if (pos == string::npos) {
                LOG_DEBUG("ignoring line in output: {1}", line);
                return true;
            }
            // Add as a string fact
            string fact = line.substr(0, pos);
            boost::to_lower(fact);
            facts.add_external(move(fact), make_value<string_value>(line.substr(pos+1)));
            return true;
        })) {
            throw external_fact_exception(_("file could not be opened."));
        }

        LOG_DEBUG("completed resolving facts from text file \"{1}\".", _path);
    }

}}}  // namespace facter::facts::external
