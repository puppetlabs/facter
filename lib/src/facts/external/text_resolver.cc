#include <internal/facts/external/text_resolver.hpp>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <leatherman/file_util/file.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/algorithm/string.hpp>

using namespace std;

namespace lth_file = leatherman::file_util;

namespace facter { namespace facts { namespace external {

    bool text_resolver::can_resolve(string const& path) const
    {
        return boost::iends_with(path, ".txt");
    }

    void text_resolver::resolve(string const& path, collection& facts) const
    {
        LOG_DEBUG("resolving facts from text file \"%1%\".", path);

        if (!lth_file::each_line(path, [&facts](string& line) {
            auto pos = line.find('=');
            if (pos == string::npos) {
                LOG_DEBUG("ignoring line in output: %1%", line);
                return true;
            }
            // Add as a string fact
            string fact = line.substr(0, pos);
            boost::to_lower(fact);
            facts.add(move(fact), make_value<string_value>(line.substr(pos+1)));
            return true;
        })) {
            throw external_fact_exception("file could not be opened.");
        }

        LOG_DEBUG("completed resolving facts from text file \"%1%\".", path);
    }

}}}  // namespace facter::facts::external
