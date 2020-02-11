#include <facter/facts/external/resolver.hpp>
#include <boost/filesystem.hpp>

using namespace std;

namespace facter { namespace facts { namespace external {

    external_fact_exception::external_fact_exception(string const& message) :
        runtime_error(message)
    {
    }

    external_fact_no_resolver::external_fact_no_resolver(std::string const& message) :
        runtime_error(message)
    {
    }

    resolver::resolver(std::string const &path):_path(path) {
      boost::filesystem::path p(path);
      _name =p.filename().string();
    }

    string const& resolver::name() const
    {
        return _name;
    }

    vector<string> const& resolver::names() const
    {
        return _names;
    }
}}}  // namespace facter::facts::external
