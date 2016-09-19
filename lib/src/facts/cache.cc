#include <internal/facts/cache.hpp>
#include <internal/facts/external/json_resolver.hpp>

#include <rapidjson/document.h>
#include <rapidjson/prettywriter.h>
#include <leatherman/logging/logging.hpp>
#include <leatherman/file_util/directory.hpp>
#include <leatherman/file_util/file.hpp>
#include <boost/nowide/fstream.hpp>
#include <time.h>

using namespace std;
using namespace rapidjson;
using namespace facter::facts::external;
namespace boost_file = boost::filesystem;

namespace facter { namespace facts { namespace cache {

    bool cache_is_valid(boost_file::path const& cache_dir, int64_t ttl) {
        time_t last_mod = boost_file::last_write_time(cache_dir);
        time_t now;
        double lifetime_seconds = difftime(time(&now), last_mod);
        return static_cast<int64_t>(lifetime_seconds) < ttl;
    }

    void load_facts_from_cache(boost_file::path const& cache_dir, shared_ptr<resolver> res, collection& facts) {
        for (auto name : res->names()) {
            string cached_fact_file = (cache_dir / name).string();
            if (leatherman::file_util::file_readable(cached_fact_file)) {
                try {
                    json_resolver json_res;
                    json_res.resolve(cached_fact_file, facts);
                } catch (external_fact_exception& ex) {
                    LOG_DEBUG("cache for {1} facts contained invalid JSON files, refreshing", res->name());
                    refresh_cache(res, cache_dir, facts);
                    return;
                }
            } else {
                LOG_DEBUG("cache for {1} facts was missing files, refreshing", res->name());
                refresh_cache(res, cache_dir, facts);
                return;
            }
        }
    }

    void refresh_cache(shared_ptr<resolver> res, boost_file::path const& cache_dir, collection& facts) {
        res->resolve(facts);
        boost_file::remove_all(cache_dir);
        boost_file::create_directories(cache_dir);
        for (auto name : res->names()) {
            boost_file::path fact_path = cache_dir / name;
            write_json_cache_file(facts, fact_path.string(), name);
        }
    }

    void use_cache(collection& facts, shared_ptr<resolver> res, int64_t ttl) {
        boost_file::path cache_dir = boost_file::path(fact_cache_location() + res->name());
        if (boost_file::is_directory(cache_dir) && cache_is_valid(cache_dir, ttl)) {
            LOG_DEBUG("loading cached values for {1} facts", res->name());
            load_facts_from_cache(cache_dir, res, facts);
        } else {
            LOG_DEBUG("caching values for {1} facts", res->name());
            refresh_cache(res, cache_dir, facts);
        }
    }

    void write_json_cache_file(collection& facts, boost_file::path const& file_path, vector<string> const& fact_names)
    {
        json_document document;
        document.SetObject();

        auto builder = ([&](string const& key, value const* val) {
            json_value value;
            if (val) {
                val->to_json(document.GetAllocator(), value);
            } else {
                value.SetString("", 0);
            }
            document.AddMember(StringRef(key.c_str(), key.size()), value, document.GetAllocator());
        });

        auto fact_value = facts.get_resolved(fact_name);
        if (fact_value) {
            builder(fact_name, fact_value);
        }

        string file_path_string = file_path.string();
        boost::nowide::ofstream stream(file_path_string);
        stream_adapter adapter(stream);
        PrettyWriter<stream_adapter> writer(adapter);
        writer.SetIndent(' ', 2);
        document.Accept(writer);
    }

}}}  // namespace facter::facts::cache
