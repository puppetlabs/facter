#include <catch.hpp>
#include "../fixtures.hpp"

#include<internal/facts/cache.hpp>
#include <facter/facts/scalar_value.hpp>

#include <leatherman/file_util/file.hpp>

using namespace std;
using namespace facter::testing;
using namespace facter::facts;
namespace boost_file = boost::filesystem;

struct simple_resolver : facter::facts::resolver
{
    simple_resolver() : resolver("test", { "foo" })
    {
    }

    virtual void resolve(collection& facts) override
    {
        facts.add("foo", make_value<string_value>("bar"));
    }

    bool is_blockable() const override
    {
        return true;
    }
};

SCENARIO("refreshing cache") {
    boost_file::path cache_dir(LIBFACTER_TESTS_DIRECTORY + string("/fixtures/cache"));

    GIVEN("a resolver that needs to be cached") {
        collection_fixture facts;
        auto test_res = make_shared<simple_resolver>();
        boost_file::create_directories(cache_dir);

        THEN("new JSON files should be written") {
            auto cache_file = (cache_dir / "test").string();
            REQUIRE_FALSE(leatherman::file_util::file_readable(cache_file));

            cache::refresh_cache(test_res, cache_file, facts);
            REQUIRE(leatherman::file_util::file_readable(cache_file));
            string contents;
            load_fixture("cache/test", contents);
            REQUIRE(contents.find("foo") != string::npos);
        }
    }

    // Clean up directory
    boost_file::remove_all(cache_dir);
}

SCENARIO("loading facts from cache") {
    boost_file::path cache_dir(LIBFACTER_TESTS_DIRECTORY + string("/fixtures/cache"));

    GIVEN("an existing cache directory with cached fact") {
        collection_fixture facts;
        auto test_res = make_shared<simple_resolver>();
        boost_file::create_directories(cache_dir);
        auto cache_file = cache_dir / "test";
        leatherman::file_util::atomic_write_to_file("{ \"foo\" : \"bar\" }", cache_file.string());

        THEN("facts should be loaded from the cache") {
            cache::load_facts_from_cache(cache_file, test_res, facts);
            REQUIRE(facts.get_resolved("foo"));
        }
    }

    // Clean up directory
    boost_file::remove_all(cache_dir);
}

SCENARIO("cleaning the cache") {
    boost_file::path cache_dir(LIBFACTER_TESTS_DIRECTORY + string("/fixtures/cache"));

    GIVEN("an existing cache directory with a fact that should no longer be cached") {
        boost_file::create_directories(cache_dir);
        // unused cache file
        auto unused_cache_file = (cache_dir / "unused").string();
        leatherman::file_util::atomic_write_to_file("{ \"foo\" : \"bar\" }",
                unused_cache_file);
        // used cached file
        auto used_cache_file = (cache_dir / "test").string();
        leatherman::file_util::atomic_write_to_file("{ \"foo\" : \"bar\" }",
                used_cache_file);

        THEN("unused cache file should be deleted") {
            // cache "test", but not "unused"
            cache::clean_cache(unordered_map<string, int64_t>({
                        make_pair("test", 600)
                        }), cache_dir.string());
            REQUIRE_FALSE(leatherman::file_util::file_readable(unused_cache_file));
            REQUIRE(leatherman::file_util::file_readable(used_cache_file));
        }
    }

    boost_file::remove_all(cache_dir);
}
