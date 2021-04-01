#include <facter/facts/collection.hpp>
#include <facter/facts/external_resolvers_factory.hpp>
#include <facter/facts/resolver.hpp>
#include <facter/facts/value.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/facts/array_value.hpp>
#include <facter/facts/map_value.hpp>
#include <facter/ruby/ruby.hpp>
#include <facter/util/string.hpp>
#include <facter/version.h>
#include <internal/facts/resolvers/hypervisors_resolver.hpp>
#include <internal/facts/resolvers/ruby_resolver.hpp>
#include <internal/facts/resolvers/path_resolver.hpp>
#include <internal/facts/resolvers/az_resolver.hpp>
#include <internal/facts/resolvers/cloud_resolver.hpp>
#include <internal/facts/resolvers/ec2_resolver.hpp>
#include <internal/facts/resolvers/gce_resolver.hpp>
#include <internal/facts/resolvers/augeas_resolver.hpp>
#include <internal/ruby/ruby_value.hpp>
#include <internal/facts/cache.hpp>
#include <leatherman/dynamic_library/dynamic_library.hpp>
#include <leatherman/file_util/directory.hpp>
#include <leatherman/util/environment.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <rapidjson/document.h>
#include <rapidjson/prettywriter.h>
#include <yaml-cpp/yaml.h>
#include <algorithm>

using namespace std;
using namespace facter::util;
using namespace rapidjson;
using namespace YAML;
using namespace boost::filesystem;
using namespace leatherman::util;
using namespace leatherman::file_util;
using facter::util::maybe_stoi;

namespace facter { namespace facts {

    collection::collection(set<string> const& blocklist, unordered_map<string, int64_t> const& ttls,
                           bool ignore_cache, bool sanitize_fact_name) :
        _blocklist(blocklist), _ttls(ttls), _ignore_cache(ignore_cache), _sanitize_fact_name(sanitize_fact_name)
    {
        // This needs to be defined here since we use incomplete types in the header
        if (sanitize_fact_name) {
            LOG_DEBUG("Fact names will be sanitized since `sanitize-fact-name` is set");
        }
    }

    collection::~collection()
    {
        // This needs to be defined here since we use incomplete types in the header
    }

    collection::collection(collection&& other)
    {
        *this = std::move(other);
    }

    collection& collection::operator=(collection&& other)
    {
        if (this != &other) {
            _facts = std::move(other._facts);
            _resolvers = std::move(other._resolvers);
            _resolver_map = std::move(other._resolver_map);
            _pattern_resolvers = std::move(other._pattern_resolvers);
            _blocklist = std::move(other._blocklist);
            _ttls = std::move(other._ttls);
        }
        return *this;
    }

    void collection::add_default_facts(bool include_ruby_facts)
    {
        add_common_facts(include_ruby_facts);
        add_platform_facts();
    }

    void collection::add(shared_ptr<resolver> const& res)
    {
        if (!res) {
            return;
        }

        for (auto const& name : res->names()) {
            _resolver_map.insert({ name, res });
        }

        if (res->has_patterns()) {
            _pattern_resolvers.push_back(res);
        }

        _resolvers.push_back(res);
    }

    void collection::add(string name, unique_ptr<value> value)
    {
        if (_sanitize_fact_name) {
            name = sanitize_fact_name(name);
        }
        // Ensure the fact is resolved before replacing it
        auto old_value = get_value(name);

        if (LOG_IS_DEBUG_ENABLED()) {
            if (old_value) {
                ostringstream old_value_ss;
                old_value->write(old_value_ss);
                if (!value) {
                    LOG_DEBUG("fact \"{1}\" resolved to null and the existing value of {2} will be removed.", name, old_value_ss.str());
                } else {
                    ostringstream new_value_ss;
                    value->write(new_value_ss);
                    if (old_value->weight() > value->weight()) {
                      LOG_DEBUG("new value for fact \"{1}\" ignored, because it's a lower weight", name);
                    } else {
                      LOG_DEBUG("fact \"{1}\" has changed from {2} to {3}.", name, old_value_ss.str(), new_value_ss.str());
                    }
                }
            } else {
                if (!value) {
                    LOG_DEBUG("fact \"{1}\" resolved to null and will not be added.", name);
                } else {
                    ostringstream new_value_ss;
                    value->write(new_value_ss);
                    LOG_DEBUG("fact \"{1}\" has resolved to {2}.", name, new_value_ss.str());
                }
            }
        }

        if (!value) {
            if (old_value) {
                remove(name);
            }
            return;
        }

        // keep existing value if it has a larger weight value
        if (old_value && old_value->weight() > value->weight())
            return;

        _facts[move(name)] = move(value);
    }

    void collection::add_custom(string name, unique_ptr<value> value, size_t weight)
    {
        if (value)
            value->weight(weight);
        add(move(name), move(value));
    }

    void collection::add_external(string name, unique_ptr<value> value)
    {
        if (value)
            value->weight(external_fact_weight);
        add(move(name), move(value));
    }

    void collection::get_external_facts_files_from_dir(external_files_list& files,
                                                       string const& dir, bool warn)
    {
        // If dir is relative, make it an absolute path before passing to can_resolve.
        boost::system::error_code ec;
        path search_dir = absolute(dir);

        if (!is_directory(search_dir, ec)) {
            // Warn the user if not using the default search directories
            string msg = ec ? ec.message() : "not a directory";
            if (warn) {
                LOG_WARNING("skipping external facts for \"{1}\": {2}", dir, msg);
            } else {
                LOG_DEBUG("skipping external facts for \"{1}\": {2}", dir, msg);
            }
            return;
        }

        LOG_DEBUG("searching {1} for external facts.", search_dir);
        external_resolvers_factory erf;
        each_file(search_dir.string(), [&](string const& path) {
            try {
                auto resolver = erf.get_resolver(path);
                files.push_back(make_pair(path, resolver));
            } catch (external::external_fact_no_resolver& e) {
                LOG_DEBUG("skipping file \"{1}\": {2}", path, e.what());
            }
            return true;
        });
    }

    map<string, vector<string>> collection::get_external_facts_groups(vector<string> const& directories)
    {
        map<string, vector<string>> external_facts_groups;
        for (auto const& it : get_external_facts_files(directories)) {
          external_facts_groups[it.second->name()] = {};
        }
        return external_facts_groups;
    }
    collection::external_files_list collection::get_external_facts_files(vector<string> const& directories)
    {
        external_files_list external_facts_files;
        // Build a list of pairs of files and the resolver that can resolve it
        // Start with default Facter search directories, then user-specified directories.
        for (auto const& dir : get_external_fact_directories()) {
            get_external_facts_files_from_dir(external_facts_files, dir, false);
        }
        for (auto const& dir : directories) {
            get_external_facts_files_from_dir(external_facts_files, dir, true);
        }
        return external_facts_files;
    }

    bool collection:: get_sanitize_fact_name(){
      return _sanitize_fact_name;
    }

    void collection::add_external_facts(vector<string> const& directories)
    {
        external_files_list external_facts_files = get_external_facts_files(directories);
        if (external_facts_files.empty()) {
            LOG_DEBUG("no external facts were found.");
        } else {
          map<string, string> known_external_facts_cache_groups;
            for (auto const& kvp : external_facts_files) {
                // Check if the resolver should be cached
                auto resolver_ttl = _ttls.find(kvp.second->name());
                if (!_ignore_cache && resolver_ttl != _ttls.end()) {
                    auto resolver = kvp.second;
                    auto it = known_external_facts_cache_groups.find(resolver->name());

                    if ( it != known_external_facts_cache_groups.end() ) {
                      LOG_ERROR(
                          "Caching is enabled for group \"{1}\" while there "
                          "are at least two external facts files with "
                          "the same filename. To fix this either remove "
                          "\"{1}\" from cached "
                          "groups or rename one of the "
                          "files:\n\"{2}\"\n\"{3}\" ",
                          resolver->name(), kvp.first, it->second);
                      break;
                    }
                    known_external_facts_cache_groups.insert(make_pair(resolver->name(), kvp.first));
                    cache::use_cache(*this, resolver, (*resolver_ttl).second);
                    continue;
                }
                try {
                    kvp.second->resolve(*this);
                }
                catch (external::external_fact_exception& ex) {
                  LOG_ERROR(
                      "error while processing \"{1}\" for external facts: {2}",
                      kvp.first, ex.what());
                }
            }
        }
    }

    void collection::add_environment_facts(function<void(string const& name)> callback)
    {
        environment::each([&](string& name, string& value) {
            // If the variable starts with "FACTER_", the remainder of the variable is the fact name
            if (!boost::istarts_with(name, "FACTER_")) {
                return true;
            }

            auto fact_name = name.substr(7);
            boost::to_lower(fact_name);
            LOG_DEBUG("setting fact \"{1}\" based on the value of environment variable \"{2}\".", fact_name, name);

            // Add the value based on the environment variable
            auto fact_value = make_value<string_value>(move(value));
            fact_value->weight(external_fact_weight);
            add(fact_name, move(fact_value));
            if (callback) {
                callback(fact_name);
            }
            return true;
        });
    }

    void collection::remove(shared_ptr<resolver> const& res)
    {
        if (!res) {
            return;
        }

        // Remove all name associations
        for (auto const& name : res->names()) {
            auto range = _resolver_map.equal_range(name);
            auto it = range.first;
            while (it != range.second) {
                if (it->second != res) {
                    ++it;
                    continue;
                }
                it = _resolver_map.erase(it);
            }
        }

        _pattern_resolvers.remove(res);
        _resolvers.remove(res);
    }

    void collection::remove(string const& name)
    {
        // Ensure the fact is in the collection
        // This will properly resolve the fact prior to removing it
        if (!get_value(name)) {
            return;
        }

        _facts.erase(name);
    }

    void collection::clear()
    {
        _facts.clear();
        _resolvers.clear();
        _resolver_map.clear();
        _pattern_resolvers.clear();
    }

    bool collection::empty()
    {
        return _facts.empty() && _resolvers.empty();
    }

    map<string, vector<string>> collection::get_fact_groups() {
        map<string, vector<string>> fact_groups;
        for (auto res : _resolvers) {
            fact_groups.emplace(res->name(), res->names());
        }
        return fact_groups;
    }

    map<string, vector<string>> collection::get_blockable_fact_groups() {
        map<string, vector<string>> blockgroups;
        for (auto res : _resolvers) {
            if (res->is_blockable()) {
                blockgroups.emplace(res->name(), res->names());
            }
        }
        return blockgroups;
    }

    size_t collection::size()
    {
        resolve_facts();
        return _facts.size();
    }

    const std::unordered_map<std::string, int64_t>& collection::get_ttls() {
        return _ttls;
    }

    value const* collection::operator[](string const& name)
    {
        return get_value(name);
    }

    void collection::each(function<bool(string const&, value const*)> func)
    {
        resolve_facts();

        // We intentionally are using find_if with no return value as a "map until" construct.
        // cppcheck-suppress ignoredReturnValue
        find_if(begin(_facts), end(_facts), [&func](map<string, unique_ptr<value>>::value_type const& it) {
            return !func(it.first, it.second.get());
        });
    }

    ostream& collection::write(ostream& stream, format fmt, set<string> const& queries)
    {
        return write(stream, fmt, queries, false, false);
    }

    ostream& collection::write(ostream& stream, format fmt, set<string> const& queries, bool show_legacy, bool strict_errors)
    {
        if (queries.empty()) {
            // Resolve all facts
            resolve_facts();
        }

        if (fmt == format::hash) {
            write_hash(stream, queries, show_legacy, strict_errors);
        } else if (fmt == format::json) {
            write_json(stream, queries, show_legacy, strict_errors);
        } else if (fmt == format::yaml) {
            write_yaml(stream, queries, show_legacy, strict_errors);
        }
        return stream;
    }

    bool collection::try_block(shared_ptr<resolver> const& res) {
        if (_blocklist.count(res->name())) {
            if (res->is_blockable()) {
                LOG_DEBUG("blocking collection of {1} facts.", res->name());
                return true;
            } else {
                LOG_DEBUG("{1} resolver cannot be blocked.", res->name());
            }
        }
        return false;
    }

    void collection::resolve(shared_ptr<resolver> const& res) {
        remove(res);

        // Check if the resolver has been blocked
        if (try_block(res)) {
            return;
        }

        // Check if the resolver should be cached
        auto resolver_ttl = _ttls.find(res->name());
        if (!_ignore_cache && resolver_ttl != _ttls.end()) {
           cache::use_cache(*this, res, (*resolver_ttl).second);
           return;
        }

        // Resolve normally
        LOG_DEBUG("resolving {1} facts.", res->name());
        try {
            res->resolve(*this);
        } catch (std::runtime_error &e) {
            LOG_WARNING("exception resolving {1} facts, some facts will not be available: {2}", res->name(), e.what());
        }
    }

    void collection::resolve_facts()
    {
        // Delete any unused cache files
        if (!_ignore_cache) {
            cache::clean_cache(_ttls);
        }
        // Remove the front of the resolvers list and resolve until no resolvers are left
        while (!_resolvers.empty()) {
            auto resolver = _resolvers.front();
            resolve(resolver);
       }
    }

    void collection::resolve_fact(string const& name)
    {
        // Resolve every resolver mapped to this name first
        auto range = _resolver_map.equal_range(name);
        auto it = range.first;
        while (it != range.second) {
            auto resolver = (it++)->second;
            resolve(resolver);
        }

         // Resolve every resolver that matches the given name
        auto pattern_it = _pattern_resolvers.begin();
        while (pattern_it != _pattern_resolvers.end()) {
            if (!(*pattern_it)->is_match(name)) {
                ++pattern_it;
                continue;
            }
            auto resolver = *(pattern_it++);
            resolve(resolver);
        }
    }

    value const* collection::get_value(string const& name)
    {
        resolve_fact(name);

        // Lookup the fact
        auto it = _facts.find(name);
        return it == _facts.end() ? nullptr : it->second.get();
    }

    value const* collection::query_value(string const& query, bool strict_errors)
    {
        // First attempt to lookup a fact with the exact name of the query
        value const* current = get_value(query);
        if (current) {
            return current;
        }

        bool in_quotes = false;
        vector<string> segments;
        string segment;
        for (auto const& c : query) {
            if (c == '"') {
                in_quotes = !in_quotes;
                continue;
            }
            if (in_quotes || c != '.') {
                segment += c;
                continue;
            }
            segments.emplace_back(move(segment));
            segment.clear();
        }
        if (!segment.empty()) {
            segments.emplace_back(move(segment));
        }

        auto segment_end = end(segments);
        for (auto segment = begin(segments); segment != segment_end; ++segment) {
            auto rb_val = dynamic_cast<ruby::ruby_value const *>(current);
            if (rb_val) {
                current = facter::ruby::lookup(current, segment, segment_end);
                if (!current) {
                    LOG_DEBUG("cannot lookup an element with \"{1}\" from Ruby fact", *segment);
                }
                // Once we hit Ruby there's no going back, so whatever we get from Ruby is the value.
                return current;
            } else {
                current = lookup(current, *segment, strict_errors);
            }
            if (!current) {
                // Break out early if there's no value for this segment
                return nullptr;
            }
        }

        return current;
    }

    value const* collection::lookup(value const* value, string const& name, bool strict_errors)
    {
        if (!value) {
            value = get_value(name);
            if (!value) {
                string message = "fact \"{1}\" does not exist.";
                if (strict_errors) {
                    LOG_ERROR(message, name);
                } else {
                    LOG_DEBUG(message, name);
                }
            }
            return value;
        }

        auto map = dynamic_cast<map_value const*>(value);
        if (map) {
            value = (*map)[name];
            if (!value) {
                LOG_DEBUG("cannot lookup a hash element with \"{1}\": element does not exist.", name);
            }
            return value;
        }

        auto array = dynamic_cast<array_value const*>(value);
        if (!array) {
            return nullptr;
        }

        auto maybe_index = maybe_stoi(name);;
        if (!maybe_index) {
            LOG_DEBUG("cannot lookup an array element with \"{1}\": expected an integral value.", name);
            return nullptr;
        }

        int index = maybe_index.get();
        if (index < 0) {
            LOG_DEBUG("cannot lookup an array element with \"{1}\": expected a non-negative value.", name);
            return nullptr;
        }

        if (array->empty()) {
            LOG_DEBUG("cannot lookup an array element with \"{1}\": the array is empty.", name);
            return nullptr;
        }

        if (static_cast<size_t>(index) >= array->size()) {
            LOG_DEBUG("cannot lookup an array element with \"{1}\": expected an integral value between 0 and {2} (inclusive).", name, array->size() - 1);
            return nullptr;
        }

        return (*array)[index];
    }

    void collection::write_hash(ostream& stream, set<string> const& queries, bool show_legacy, bool strict_errors)
    {
        // If there's only one query, print the result without the name
        if (queries.size() == 1u) {
            auto value = query_value(*queries.begin(), strict_errors);
            if (value) {
                value->write(stream, false);
            }
            return;
        }

        bool first = true;
        auto writer = ([&](string const& key, value const* val) {
            // Ignore facts with hidden values
            if (!show_legacy && queries.empty() && val && val->hidden()) {
                return;
            }
            if (first) {
                first = false;
            } else {
                stream << '\n';
            }
            stream << key << " => ";
            if (val) {
                val->write(stream, false);
            }
        });

        if (!queries.empty()) {
            // Print queried facts
            vector<pair<string, value const*>> facts;
            for (auto const& query : queries) {
                facts.push_back(make_pair(query, this->query_value(query, strict_errors)));
            }

            for (auto const& kvp : facts) {
                writer(kvp.first, kvp.second);
            }
        } else {
            // Print all facts in the map
            for (auto const& kvp : _facts) {
                writer(kvp.first, kvp.second.get());
            }
        }
    }

    void collection::write_json(ostream& stream, set<string> const& queries, bool show_legacy, bool strict_errors)
    {
        json_document document;
        document.SetObject();

        auto builder = ([&](string const& key, value const* val) {
            // Ignore facts with hidden values
            if (!show_legacy && queries.empty() && val && val->hidden()) {
                return;
            }
            json_value value;
            if (val) {
                val->to_json(document.GetAllocator(), value);
            } else {
                value.SetString("", 0);
            }
            document.AddMember(StringRef(key.c_str(), key.size()), value, document.GetAllocator());
        });

        if (!queries.empty()) {
            for (auto const& query : queries) {
                builder(query, this->query_value(query, strict_errors));
            }
        } else {
            for (auto const& kvp : _facts) {
                builder(kvp.first, kvp.second.get());
            }
        }

        stream_adapter adapter(stream);
        PrettyWriter<stream_adapter> writer(adapter);
        writer.SetIndent(' ', 2);
        document.Accept(writer);
    }

    void collection::write_yaml(ostream& stream, set<string> const& queries, bool show_legacy, bool strict_errors)
    {
        Emitter emitter(stream);
        emitter << BeginMap;

        auto writer = ([&](string const& key, value const* val) {
            // Ignore facts with hidden values
            if (!show_legacy && queries.empty() && val && val->hidden()) {
                return;
            }
            emitter << Key;
            if (needs_quotation(key)) {
                emitter << DoubleQuoted;
            }
            emitter << key << YAML::Value;
            if (val) {
                val->write(emitter);
            } else {
                emitter << DoubleQuoted << "";
            }
        });

        if (!queries.empty()) {
            vector<pair<string, value const*>> facts;
            for (auto const& query : queries) {
                facts.push_back(make_pair(query, this->query_value(query, strict_errors)));
            }

            for (auto const& kvp : facts) {
                writer(kvp.first, kvp.second);
            }
        } else {
            for (auto const& kvp : _facts) {
                writer(kvp.first, kvp.second.get());
            }
        }
        emitter << EndMap;
    }

    void collection::add_common_facts(bool include_ruby_facts)
    {
        add("facterversion", make_value<string_value>(LIBFACTER_VERSION));
#ifdef AIO_AGENT_VERSION
        add("aio_agent_version", make_value<string_value>(AIO_AGENT_VERSION));
#endif

        if (include_ruby_facts) {
            add(make_shared<resolvers::ruby_resolver>());
        }
        add(make_shared<resolvers::path_resolver>());
        add(make_shared<resolvers::az_resolver>());
        add(make_shared<resolvers::ec2_resolver>());
        add(make_shared<resolvers::cloud_resolver>());
        add(make_shared<resolvers::gce_resolver>());
        add(make_shared<resolvers::augeas_resolver>());
#ifdef USE_WHEREAMI
        add(make_shared<resolvers::hypervisors_resolver>());
#endif
    }

}}  // namespace facter::facts
