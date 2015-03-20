#include <internal/util/scoped_env.hpp>
#include <facter/util/environment.hpp>

using namespace std;

namespace facter { namespace util {

    scoped_env::scoped_env(string var, string const& val) : scoped_resource()
    {
        string oldval;
        bool was_set = environment::get(var, oldval);
        environment::set(var, val);

        _resource = make_tuple(move(var), was_set ? boost::optional<std::string>(move(oldval)) : boost::none);
        _deleter = scoped_env::restore;
    }

    void scoped_env::restore(tuple<string, boost::optional<std::string>> & old)
    {
        if (get<1>(old)) {
            environment::set(get<0>(old), *get<1>(old));
        } else {
            environment::clear(get<0>(old));
        }
    }

}}  // namespace facter::util
