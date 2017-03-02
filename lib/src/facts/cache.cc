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

    bool cache_is_valid(boost_file::path const& cache_file, int64_t ttl) {
        time_t last_mod = boost_file::last_write_time(cache_file);
        time_t now;
        double lifetime_seconds = difftime(time(&now), last_mod);
        return static_cast<int64_t>(lifetime_seconds) < ttl;
    }

    void load_facts_from_cache(boost_file::path const& cache_file, shared_ptr<resolver> res, collection& facts) {
        string cache_file_path = cache_file.string();
        if (leatherman::file_util::file_readable(cache_file_path)) {
            try {
                json_resolver json_res;
                json_res.resolve(cache_file_path, facts);
            } catch (external_fact_exception& ex) {
                LOG_DEBUG("cache file for {1} facts contained invalid JSON, refreshing", res->name());
                refresh_cache(res, cache_file, facts);
                return;
            }
        } else {
            LOG_DEBUG("cache file for {1} facts was missing, refreshing", res->name());
            refresh_cache(res, cache_file, facts);
            return;
        }
    }

    void refresh_cache(shared_ptr<resolver> res, boost_file::path const& cache_file, collection& facts) {
        res->resolve(facts);
        boost_file::remove(cache_file);
        write_json_cache_file(facts, cache_file.string(), res->names());
    }

    void use_cache(collection& facts, shared_ptr<resolver> res, int64_t ttl) {
        boost_file::path cache_dir = boost_file::path(fact_cache_location());
        if (!boost_file::is_directory(cache_dir)) {
            boost_file::create_directories(cache_dir);
        }
        boost_file::path cache_file = cache_dir / res->name();
        if (leatherman::file_util::file_readable(cache_file.string()) && cache_is_valid(cache_file, ttl)) {
            LOG_DEBUG("loading cached values for {1} facts", res->name());
            load_facts_from_cache(cache_file, res, facts);
        } else {
            LOG_DEBUG("caching values for {1} facts", res->name());
            refresh_cache(res, cache_file, facts);
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

        for (auto const& name : fact_names) {
            auto fact_value = facts.get_resolved(name);
            if (fact_value) {
                builder(name, fact_value);
            }
        }

        string file_path_string = file_path.string();
        boost::nowide::ofstream stream(file_path_string);
        stream_adapter adapter(stream);
        PrettyWriter<stream_adapter> writer(adapter);
        writer.SetIndent(' ', 2);
        document.Accept(writer);
    }

}}}  // namespace facter::facts::cache
