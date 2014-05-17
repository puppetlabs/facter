#include <facter/facterlib.h>
#include <facter/version.h>
#include <facter/facts/fact_map.hpp>
#include <facter/facts/value.hpp>
#include <facter/util/string.hpp>
#include <log4cxx/logger.h>
#include <memory>

using namespace std;
using namespace facter::util;
using namespace facter::facts;
using namespace log4cxx;

static unique_ptr<fact_map> g_facts;

extern "C" {
    char const* get_facter_version()
    {
        return LIBFACTER_VERSION;
    }

    void load_facts(char const* names)
    {
        // TODO: figure out a callback mechanism for log output
        // Until then, disable logging when using the C interface
        if (Logger::getRootLogger()->getAllAppenders().size() == 0) {
            Logger::getRootLogger()->setLevel(Level::getOff());
        }

        g_facts.reset(new fact_map());

        set<string> requested_facts;
        if (names) {
            for (auto& name : split(names, ',')) {
                requested_facts.emplace(trim(to_lower(move(name))));
            }
        }
        g_facts->resolve(requested_facts);
    }

    void clear_facts()
    {
        if (!g_facts) {
            return;
        }
        g_facts.reset(nullptr);
    }

    void enumerate_facts(enumeration_callbacks* callbacks)
    {
        if (!g_facts || !callbacks) {
            return;
        }
        g_facts->each([&](string const& name, value const* val) {
            val->notify(name, callbacks);
            return true;
        });
    }

    bool get_fact_value(char const* name, enumeration_callbacks* callbacks)
    {
        if (!g_facts || !name || !callbacks) {
            return false;
        }

        // Get the fact
        string fact = trim(to_lower(name));
        auto val = (*g_facts)[fact];
        if (!val) {
            return false;
        }

        // Notify of the fact value
        val->notify(fact, callbacks);
        return true;
    }

    void search_external(char const* directories)
    {
        // TODO: implement
    }
}
