#include <facter/facterlib.h>
#include <facter/version.h>
#include <facter/facts/collection.hpp>
#include <facter/facts/value.hpp>
#include <facter/util/string.hpp>
#include <log4cxx/logger.h>
#include <memory>
#include <vector>
#include <string>

using namespace std;
using namespace facter::util;
using namespace facter::facts;
using namespace log4cxx;

static unique_ptr<collection> g_facts;
static vector<string> g_fact_directories;
static vector<string> g_external_directories;

extern "C" {
    char const* get_facter_version()
    {
        return LIBFACTER_VERSION;
    }

    void load_facts(char const* names)
    {
        if (g_facts) {
            return;
        }

        // TODO: figure out a callback mechanism for log output
        // Until then, disable logging when using the C interface
        if (Logger::getRootLogger()->getAllAppenders().size() == 0) {
            Logger::getRootLogger()->setLevel(Level::getOff());
        }

        g_facts.reset(new collection());

        set<string> requested_facts;
        if (names) {
            for (auto& name : split(names, ',')) {
                requested_facts.emplace(trim(to_lower(move(name))));
            }
        }

        // Resolve facts
        g_facts->resolve(requested_facts);

        // Load external facts
        g_facts->resolve_external(g_external_directories, requested_facts);
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

    void add_search_paths(char const* directories, char const* separator)
    {
        if (!directories || !separator || !*separator) {
            return;
        }

        for (auto& directory : split(directories, *separator)) {
            g_fact_directories.emplace_back(move(directory));
        }
    }

    void enumerate_search_paths(void(*callback)(char const* path))
    {
        if (!callback) {
            return;
        }
        for (auto const& directory : g_fact_directories) {
            callback(directory.c_str());
        }
    }

    void clear_search_paths()
    {
        g_fact_directories.clear();
    }

    void add_external_search_paths(char const* directories, char const* separator)
    {
        if (!directories || !separator || !*separator) {
            return;
        }

        for (auto& directory : split(directories, *separator)) {
            g_external_directories.emplace_back(move(directory));
        }
    }

    void enumerate_external_search_paths(void(*callback)(char const* path))
    {
        if (!callback) {
            return;
        }
        for (auto const& directory : g_external_directories) {
            callback(directory.c_str());
        }
    }

    void clear_external_search_paths()
    {
        g_external_directories.clear();
    }
}
