#include <gmock/gmock.h>
#include <facter/facts/collection.hpp>
#include <facter/facts/scalar_value.hpp>
#include <facter/ruby/api.hpp>
#include <facter/ruby/module.hpp>
#include <facter/util/string.hpp>
#include <facter/logging/logging.hpp>
#include <log4cxx/logger.h>
#include <log4cxx/appenderskeleton.h>
#include <facter/util/regex.hpp>
#include <boost/algorithm/string/replace.hpp>
#include <memory>
#include <tuple>
#include <vector>
#include <sstream>
#include <string>
#include <map>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::ruby;
using namespace facter::util;
using namespace facter::testing;
using namespace log4cxx;
using testing::ElementsAre;

LOG_DECLARE_NAMESPACE("ruby.test");

struct ruby_log_appender : AppenderSkeleton
{
 public:
    ruby_log_appender()
    {
        setName("ruby appender");
    }

    DECLARE_LOG4CXX_OBJECT(ruby_log_appender)
    BEGIN_LOG4CXX_CAST_MAP()
        LOG4CXX_CAST_ENTRY(ruby_log_appender)
        LOG4CXX_CAST_ENTRY_CHAIN(AppenderSkeleton)
    END_LOG4CXX_CAST_MAP()

    void append(const spi::LoggingEventPtr& event, log4cxx::helpers::Pool& p)
    {
        string message = event->getMessage();

        // Strip color codes
        boost::replace_all(message, "\x1B[0;33m", "");
        boost::replace_all(message, "\x1B[0;36m", "");
        boost::replace_all(message, "\x1B[0;31m", "");
        boost::replace_all(message, "\x1B[0m", "");
        _messages.push_back({ event->getLevel()->toString(), message});
    }

    void close() {}
    bool requiresLayout() const { return false; }

    vector<pair<string, string>> const& messages() const { return _messages; }

 private:
     vector<pair<string, string>> _messages;
};

IMPLEMENT_LOG4CXX_OBJECT(ruby_log_appender);

struct ruby_test_parameters
{
    ruby_test_parameters(string const& file, string const& fact, string const& value) :
        file(file),
        failure_expected(false),
        fact(fact),
        expected(value)
    {
    }

    ruby_test_parameters(string const& file, string const& fact, string const& value, map<string, string> const& facts) :
        file(file),
        failure_expected(false),
        fact(fact),
        expected(value),
        facts(facts)
    {
    }

    ruby_test_parameters(string const& file, vector<pair<string, string>> const& messages, bool failure = false) :
        file(file),
        failure_expected(failure),
        messages(messages)
    {
    }

    ruby_test_parameters(string const& file, string const& fact) :
        file(file),
        failure_expected(false),
        fact(fact)
    {
    }

    ruby_test_parameters(string const& file, string const& fact, map<string, string> const& facts) :
        file(file),
        failure_expected(false),
        fact(fact),
        facts(facts)
    {
    }

    string file;
    bool failure_expected;
    string fact;
    string expected;
    map<string, string> facts;
    vector<pair<string, string>> messages;
};

ostream& operator<<(ostream& stream, const ruby_test_parameters& p)
{
    if (p.failure_expected) {
        stream << "expected file " << p.file << " to fail to load.";
    } else if (!p.messages.empty()) {
        stream << "expected file " << p.file << " to log ";
        bool first = true;
        for (auto const& kvp : p.messages) {
            if (first) {
                first = false;
            } else {
                stream << ',';
            }
            stream << "(" << kvp.first << " => \"" << kvp.second << "\")";
        }
        stream << ".";
    } else if (p.expected.empty()) {
        stream << "expected fact \"" << p.fact << "\" in file " << p.file << " to not resolve.";
    } else {
        stream << "expected fact \"" << p.fact << "\" in file " << p.file << " to resolve to " << p.expected << ".";
    }
    return stream;
}

struct facter_ruby : testing::TestWithParam<ruby_test_parameters>
{
 protected:
    bool load()
    {
        auto ruby = api::instance();
        if (!ruby || !ruby->initialized()) {
            LOG_ERROR("ruby is not initialized");
            return false;
        }

        module mod(*ruby, _facts);

        VALUE result = ruby->rescue([&]() {
            // Do not construct C++ objects in a rescue callback
            // C++ stack unwinding will not take place if a Ruby exception is thrown!
            ruby->rb_load(ruby->rb_str_new_cstr((LIBFACTER_TESTS_DIRECTORY "/fixtures/ruby/" + GetParam().file).c_str()), 0);
            return ruby->true_value();
        }, [&](VALUE ex) {
            LOG_ERROR("error while resolving custom facts in %1%: %2%.\nbacktrace:\n%3%",
                GetParam().file,
                ruby->to_string(ex),
                ruby->exception_backtrace(ex));
            return ruby->false_value();
        });

        mod.resolve();
        return ruby->is_true(result);
    }

    virtual void SetUp()
    {
        _facts.clear();
        for (auto const& kvp : GetParam().facts) {
            _facts.add(to_lower(string(kvp.first)), make_value<string_value>(kvp.second));
        }

        auto root = Logger::getRootLogger();

        _level = root->getLevel();
        root->setLevel(Level::getDebug());

        _appender = new ruby_log_appender();
        root->addAppender(_appender);
    }

    virtual void TearDown()
    {
        auto root = Logger::getRootLogger();

        root->setLevel(_level);
        root->removeAppender(_appender);
    }

    collection _facts;
    ruby_log_appender* _appender;
    LevelPtr _level;
};

TEST_P(facter_ruby, load)
{
    bool success = load();
    if (GetParam().failure_expected && success) {
        FAIL() << "a failure was expected but the file successfully loaded.";
    } else if (!GetParam().failure_expected && !success) {
        FAIL() << "a failure was not expected but the file failed to load.";
    }

    auto const& expected_messages = GetParam().messages;
    auto const& messages = _appender->messages();
    if (!expected_messages.empty()) {
        ASSERT_EQ(expected_messages.size(), messages.size());
        for (size_t i = 0; i < expected_messages.size(); ++i) {
            ASSERT_EQ(expected_messages[i].first, messages[i].first);
            ASSERT_TRUE(re_search(messages[i].second, expected_messages[i].second));
        }
        return;
    }

    auto value = _facts[GetParam().fact];
    if (GetParam().expected.empty()) {
        ASSERT_EQ(nullptr, value) << "fact was not expected to resolve.";
    } else {
        ASSERT_NE(nullptr, value) << "fact was expected to resolve.";

        ostringstream ss;
        value->write(ss);
        ASSERT_EQ(GetParam().expected, ss.str());
    }
}

vector<ruby_test_parameters> single_fact_tests = {
    ruby_test_parameters("nil_fact.rb", "foo"),
    ruby_test_parameters("simple.rb", "foo", "\"bar\""),
    ruby_test_parameters("simple_resolution.rb", "foo", "\"bar\""),
    ruby_test_parameters("empty_fact.rb", "foo"),
    ruby_test_parameters("empty_fact_with_value.rb", "foo", "{\"array\"=>[1, 2, 3], \"bool_false\"=>false, \"bool_true\"=>true, \"double\"=>12.34, \"int\"=>1, \"string\"=>\"foo\"}"),
    ruby_test_parameters("empty_command.rb", { { "ERROR", "expected a non-empty String for first argument" } }, true),
    ruby_test_parameters("simple_command.rb", "foo", "\"bar\""),
    ruby_test_parameters("confine_missing_fact.rb", "foo", { { "kernel", "linux" } }),
    ruby_test_parameters("bad_command.rb", "foo"),
    ruby_test_parameters("simple_confine.rb", "foo", "\"bar\"", { { "someFact", "someValue" } }),
    ruby_test_parameters("simple_confine.rb", "foo"),
    ruby_test_parameters("multi_confine.rb", "foo", "\"bar\"", { {"FACT1", "VALUE1"}, { "Fact2", "Value2" }, { "fact3", "value3" } }),
    ruby_test_parameters("multi_confine.rb", "foo"),
    ruby_test_parameters("bad_syntax.rb", { { "ERROR", "undefined method `foo' for Facter:Module" } }, true),
    ruby_test_parameters("block_confine.rb", "foo"),
    ruby_test_parameters("block_confine.rb", "foo", "\"bar\"", { { "fact1", "value1" } }),
    ruby_test_parameters("block_nil_confine.rb", "foo"),
    ruby_test_parameters("block_true_confine.rb", "foo", "\"bar\""),
    ruby_test_parameters("block_false_confine.rb", "foo"),
    ruby_test_parameters("array_confine.rb", "foo", { { "fact", "foo" } }),
    ruby_test_parameters("array_confine.rb", "foo", "\"bar\"", { { "fact", "value3" } }),
    ruby_test_parameters("confine_weight.rb", "foo", "\"value2\"", { { "fact1", "value1" }, { "fact2", "value2" }, { "fact3", "value3" } }),
    ruby_test_parameters("weight.rb", "foo", "\"value2\""),
    ruby_test_parameters("weight_option.rb", "foo", "\"value2\""),
    ruby_test_parameters("string_fact.rb", "foo", "\"hello world\""),
    ruby_test_parameters("integer_fact.rb", "foo", "1234"),
    ruby_test_parameters("boolean_true_fact.rb", "foo", "true"),
    ruby_test_parameters("boolean_false_fact.rb", "foo", "false"),
    ruby_test_parameters("double_fact.rb", "foo", "12.34"),
    ruby_test_parameters("array_fact.rb", "foo", "[1, true, false, \"foo\", 12.4, [1], {\"foo\"=>\"bar\"}]"),
    ruby_test_parameters("hash_fact.rb", "foo", "{\"array\"=>[1, 2, 3], \"bool_false\"=>false, \"bool_true\"=>true, \"double\"=>12.34, \"int\"=>1, \"string\"=>\"foo\"}"),
    ruby_test_parameters("value.rb", "foo", "\"baz\"", { { "bar", "baz" } }),
    ruby_test_parameters("fact.rb", "foo", "\"baz\"", { { "bar", "baz" } }),
    ruby_test_parameters("lookup.rb", "foo", "\"baz\"", { { "bar", "baz" } }),
    ruby_test_parameters("which.rb", "foo", "\"bar\""),
    ruby_test_parameters("debug.rb", { { "DEBUG", "^message1$" }, { "DEBUG", "^message2$" } }),
    ruby_test_parameters("debugonce.rb", { { "DEBUG", "^unique debug1$" }, { "DEBUG", "^unique debug2$" } }),
    ruby_test_parameters("warn.rb", { { "WARN", "^message1$" }, { "WARN", "^message2$" } }),
    ruby_test_parameters("warnonce.rb", { { "WARN", "^unique warning1$" }, { "WARN", "^unique warning2$" } }),
    ruby_test_parameters("log_exception.rb", { { "ERROR", "^what's up doc\\?" } }),
    ruby_test_parameters("named_resolution.rb", "foo", "\"value2\""),
    ruby_test_parameters("define_fact.rb", "foo", "\"bar\""),
    ruby_test_parameters("cycle.rb", { { "ERROR", "cycle detected while requesting value of fact \"bar\"" } }),
    ruby_test_parameters("aggregate.rb", "foo", "[\"foo\", \"bar\"]"),
    ruby_test_parameters("aggregate_with_require.rb", "foo", "[\"foo\", \"bar\", \"foo\", \"baz\", \"foo\", \"bar\", \"foo\"]"),
    ruby_test_parameters("aggregate_invalid_require.rb", { { "ERROR", "expected a Symbol or Array of Symbol for require option" } }, true),
    ruby_test_parameters("aggregate_with_block.rb", "foo", "10"),
    ruby_test_parameters("aggregate_with_merge.rb", "foo", "{\"array\"=>[1, 2, 3, 4, 5, 6], \"baz\"=>\"jam\", \"foo\"=>\"bar\", \"hash\"=>{\"foo\"=>\"bar\", \"jam\"=>\"cakes\", \"subarray\"=>[\"hello\", \"world\"]}}"),
    ruby_test_parameters("aggregate_with_invalid_merge.rb", { { "ERROR", "cannot merge \"hello\":String and \"world\":String" } }),
    ruby_test_parameters("aggregate_with_cycle.rb", { { "ERROR", "chunk dependency cycle detected" } }),
    ruby_test_parameters("define_aggregate_fact.rb", "foo", "[\"foo\", \"bar\"]"),
    ruby_test_parameters("existing_simple_resolution.rb", { { "ERROR", "cannot define an aggregate resolution with name \"bar\": a simple resolution with the same name already exists" } }, true),
    ruby_test_parameters("existing_aggregate_resolution.rb", { { "ERROR", "cannot define a simple resolution with name \"bar\": an aggregate resolution with the same name already exists" } }, true),
};

INSTANTIATE_TEST_CASE_P(run, facter_ruby, testing::ValuesIn(single_fact_tests));
