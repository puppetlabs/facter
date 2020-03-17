#include <internal/facts/cache.hpp>
#include <internal/facts/external/json_resolver.hpp>

#include <rapidjson/document.h>
#include <rapidjson/prettywriter.h>
#include <leatherman/logging/logging.hpp>
#include <leatherman/file_util/directory.hpp>
#include <leatherman/file_util/file.hpp>
#include <boost/nowide/fstream.hpp>
#include <boost/system/error_code.hpp>
#include <time.h>

using namespace std;
using namespace rapidjson;
using namespace facter::facts::external;
namespace boost_file = boost::filesystem;

namespace facter { namespace facts { namespace cache {

    void clean_cache(unordered_map<string, int64_t> const& facts_to_cache, string cache_location) {
        boost_file::path cache_dir = boost_file::path(cache_location);
        if (!boost_file::is_directory(cache_dir)) {
            return;
        }
        for (boost_file::directory_iterator itr(cache_dir);
                itr != boost_file::directory_iterator();
                ++itr) {
            boost_file::path cache_file = itr->path();
            if (!facts_to_cache.count(cache_file.filename().string())) {
                boost::system::error_code ec;
                boost_file::remove(cache_file, ec);
                if (!ec) {
                    LOG_DEBUG("Deleting unused cache file {1}", cache_file.string());
                } else {
                    continue;
                }
            }
        }
    }

    bool cache_is_valid(boost_file::path const& cache_file, int64_t ttl) {
        time_t last_mod = boost_file::last_write_time(cache_file);
        time_t now;
        double lifetime_seconds = difftime(time(&now), last_mod);
        return static_cast<int64_t>(lifetime_seconds) < ttl;
    }

    void load_facts_from_cache(boost_file::path const& cache_file, shared_ptr<base_resolver> res, collection& facts) {
        string cache_file_path = cache_file.string();
        if (leatherman::file_util::file_readable(cache_file_path)) {
            try {
                json_resolver json_res(cache_file_path);
                json_res.resolve(facts);
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

    void refresh_cache(shared_ptr<base_resolver> res, boost_file::path const& cache_file, collection& facts) {
        res->resolve(facts);
        boost_file::remove(cache_file);
        write_json_cache_file(facts, cache_file.string(), res->names());
    }

    void use_cache(collection& facts, shared_ptr<base_resolver> res, int64_t ttl) {
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

    void write_json_cache_file(const collection& facts, boost_file::path const& file_path, vector<string> const& fact_names)
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

    boost_file::path custom_fact_cache_file_location() {
        boost_file::path cache_dir = boost_file::path(facter::facts::cache::fact_cache_location());
        if (!boost_file::is_directory(cache_dir))
            boost_file::create_directories(cache_dir);
        boost_file::path custom_fact_cache_file_location = cache_dir / cached_custom_facts;

        return custom_fact_cache_file_location;
    }

    bool load_cached_custom_facts(collection& collection,  int64_t ttl)
    {
        boost_file::path cache_file = custom_fact_cache_file_location();
        if (leatherman::file_util::file_readable(cache_file.string()) && cache::cache_is_valid(cache_file, ttl)) {
            try {
                LOG_DEBUG("Loading cached custom facts from file \"{1}\"", cache_file.string());
                facts::external::json_resolver json_res(cache_file.string());
                json_res.resolve(collection);
                return true;
            } catch (exception& ex) {
                LOG_DEBUG("Custom facts cache file contained invalid JSON, refreshing");
                return false;
            }
       } else {
            LOG_DEBUG("Custom facts cache file expired/missing. Refreshing");
            boost_file::remove(cache_file);
       }
       return false;
    }

    void write_cached_custom_facts(const collection& facts, const std::vector<std::string>& cached_custom_facts_list)
    {
        boost_file::path cache_file = custom_fact_cache_file_location();
        LOG_DEBUG("Saving cached custom facts to {1}", cache_file);
        write_json_cache_file(facts, cache_file, cached_custom_facts_list);
    }
}}}  // namespace facter::facts::cache
