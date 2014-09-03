#include <facter/util/scoped_env.hpp>
#include <facter/util/environment.hpp>

using namespace std;

namespace facter { namespace util {

    scoped_env::scoped_env(string var, string val) : scoped_resource()
    {
        string oldval;
        bool was_set = environment::get(var, oldval);
        _resource = make_tuple(var, oldval, was_set);
        _deleter = scoped_env::restore;

        environment::set(var, val);
    }

    void scoped_env::restore(tuple<string, string, bool> & old)
    {
        if (get<2>(old)) {
            environment::set(get<0>(old), get<1>(old));
        } else {
            environment::clear(get<0>(old));
        }
    }

}}  // namespace facter::util
