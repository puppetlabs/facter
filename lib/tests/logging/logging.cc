#include <gmock/gmock.h>
#include <facter/logging/logging.hpp>
#include <boost/log/sinks/sync_frontend.hpp>
#include <boost/log/sinks/basic_sink_backend.hpp>
#include <boost/nowide/convert.hpp>
#include <boost/nowide/iostream.hpp>

using namespace std;
using namespace facter::logging;
namespace sinks = boost::log::sinks;

class custom_log_appender :
    public sinks::basic_formatted_sink_backend<char, sinks::synchronized_feeding>
{
 public:
    void consume(boost::log::record_view const& rec, string_type const& message)
    {
        stringstream s;
        s << rec[log_level_attr];
        _level = s.str();
        _message = message;
    }

    string const& last_level() const { return _level; }
    string const& last_message() const { return _message; }

 private:
    string _level;
    string _message;
};

struct facter_logging : ::testing::Test {
 protected:
    using sink_t = sinks::synchronous_sink<custom_log_appender>;

    virtual void SetUp()
    {
        set_level(log_level::trace);
        _appender.reset(new custom_log_appender());
        _sink.reset(new sink_t(_appender));

        auto core = boost::log::core::get();
        core->add_sink(_sink);
    }

    virtual void TearDown()
    {
        set_level(log_level::none);
        on_message(nullptr);

        auto core = boost::log::core::get();
        core->reset_filter();
        core->remove_sink(_sink);

        _sink.reset();
        _appender.reset();
    }

    boost::shared_ptr<custom_log_appender> _appender;
    boost::shared_ptr<sink_t> _sink;

    log_level _last_callback_level;
    string _last_callback_message;
};

TEST_F(facter_logging, trace) {
    ASSERT_EQ(true, LOG_IS_TRACE_ENABLED());
    LOG_TRACE("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("TRACE", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::trace)) + "testing 1 2 3" + colorize(), _appender->last_message());
    log("test", log_level::trace, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("TRACE", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::trace)) + "testing 1 2 3" + colorize(), _appender->last_message());
}

TEST_F(facter_logging, debug) {
    ASSERT_EQ(true, LOG_IS_DEBUG_ENABLED());
    LOG_DEBUG("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("DEBUG", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::debug)) + "testing 1 2 3" + colorize(), _appender->last_message());
    log("test", log_level::debug, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("DEBUG", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::debug)) + "testing 1 2 3" + colorize(), _appender->last_message());
}

TEST_F(facter_logging, info) {
    ASSERT_EQ(true, LOG_IS_INFO_ENABLED());
    LOG_INFO("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("INFO", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::info)) + "testing 1 2 3" + colorize(), _appender->last_message());
    log("test", log_level::info, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("INFO", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::info)) + "testing 1 2 3" + colorize(), _appender->last_message());
}

TEST_F(facter_logging, warning) {
    ASSERT_EQ(true, LOG_IS_WARNING_ENABLED());
    LOG_WARNING("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("WARN", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::warning)) + "testing 1 2 3" + colorize(), _appender->last_message());
    log("test", log_level::warning, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("WARN", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::warning)) + "testing 1 2 3" + colorize(), _appender->last_message());
}

TEST_F(facter_logging, error) {
    ASSERT_EQ(true, LOG_IS_ERROR_ENABLED());
    LOG_ERROR("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("ERROR", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::error)) + "testing 1 2 3" + colorize(), _appender->last_message());
    log("test", log_level::error, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("ERROR", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::error)) + "testing 1 2 3" + colorize(), _appender->last_message());
}

TEST_F(facter_logging, fatal) {
    ASSERT_EQ(true, LOG_IS_FATAL_ENABLED());
    LOG_FATAL("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("FATAL", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::fatal)) + "testing 1 2 3" + colorize(), _appender->last_message());
    log("test", log_level::fatal, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("FATAL", _appender->last_level());
    ASSERT_EQ(string(colorize(log_level::fatal)) + "testing 1 2 3" + colorize(), _appender->last_message());
}

TEST_F(facter_logging, on_message) {
    on_message([this](log_level level, string const& message) {
        _last_callback_level = level;
        _last_callback_message = message;
        return false;
    });
    LOG_DEBUG("debug message");
    ASSERT_EQ(log_level::debug, _last_callback_level);
    ASSERT_EQ("debug message", _last_callback_message);
    LOG_INFO("info message");
    ASSERT_EQ(log_level::info, _last_callback_level);
    ASSERT_EQ("info message", _last_callback_message);
    LOG_WARNING("warning message");
    ASSERT_EQ(log_level::warning, _last_callback_level);
    ASSERT_EQ("warning message", _last_callback_message);
    LOG_ERROR("error message");
    ASSERT_EQ(log_level::error, _last_callback_level);
    ASSERT_EQ("error message", _last_callback_message);
    LOG_FATAL("fatal message");
    ASSERT_EQ(log_level::fatal, _last_callback_level);
    ASSERT_EQ("fatal message", _last_callback_message);
}

TEST_F(facter_logging, unicode) {
    on_message([this](log_level level, string const& message) {
        _last_callback_level = level;
        _last_callback_message = message;
        return false;
    });

    // Test various Unicode characters
    const wstring symbols[] = {L"\u2122", L"\u2744", L"\u039b"};
    for (auto s : symbols) {
        auto utf8 = boost::nowide::narrow(s);
        LOG_INFO(utf8);
        ASSERT_EQ(log_level::info, _last_callback_level);
        ASSERT_EQ(utf8, _last_callback_message);
    }
}
