#include "ruby_helper.hpp"
#include <leatherman/logging/logging.hpp>
#include <leatherman/ruby/api.hpp>
#include <internal/ruby/module.hpp>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::ruby;
using namespace facter::facts;
using namespace leatherman::ruby;

bool load_custom_fact(string const& filename, collection& facts)
{
    auto& ruby = api::instance();

    module mod(facts);

    string file = LIBFACTER_TESTS_DIRECTORY "/fixtures/ruby/" + filename;
    VALUE result = ruby.rescue([&]() {
        // Do not construct C++ objects in a rescue callback
        // C++ stack unwinding will not take place if a Ruby exception is thrown!
        ruby.rb_load(ruby.utf8_value(file), 0);
        return ruby.true_value();
    }, [&](VALUE ex) {
        LOG_ERROR("error while resolving custom facts in %1%: %2%", file, ruby.exception_to_string(ex));
        return ruby.false_value();
    });

    mod.resolve_facts();

    return ruby.is_true(result);
}

string ruby_value_to_string(value const* value)
{
    ostringstream ss;
    if (value) {
        value->write(ss);
    }
    return ss.str();
}
