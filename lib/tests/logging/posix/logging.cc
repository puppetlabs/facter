#include <gmock/gmock.h>
#include <facter/logging/logging.hpp>
#include <boost/log/sinks/sync_frontend.hpp>
#include <boost/log/sinks/basic_sink_backend.hpp>

using namespace std;
using namespace facter::logging;
namespace sinks = boost::log::sinks;

LOG_DECLARE_NAMESPACE("logging.test");

bool g_color = isatty(fileno(stdout));

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

using sink_t = sinks::synchronous_sink<custom_log_appender>;

struct facter_logging : ::testing::Test {
 protected:
    virtual void SetUp()
    {
        _appender.reset(new custom_log_appender());
        _sink.reset(new sink_t(_appender));

        auto core = boost::log::core::get();
        core->set_filter(log_level_attr >= log_level::debug);
        core->add_sink(_sink);
    }

    virtual void TearDown()
    {
        auto core = boost::log::core::get();
        core->reset_filter();
        core->remove_sink(_sink);

        _sink.reset();
        _appender.reset();
    }

    boost::shared_ptr<custom_log_appender> _appender;
    boost::shared_ptr<sink_t> _sink;
};

TEST_F(facter_logging, debug) {
    ASSERT_EQ(true, LOG_IS_DEBUG_ENABLED());
    LOG_DEBUG("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("DEBUG", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;36mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
    log(g_logger, log_level::debug, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("DEBUG", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;36mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
}

TEST_F(facter_logging, info) {
    ASSERT_EQ(true, LOG_IS_INFO_ENABLED());
    LOG_INFO("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("INFO", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;32mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
    log(g_logger, log_level::info, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("INFO", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;32mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
}

TEST_F(facter_logging, warning) {
    ASSERT_EQ(true, LOG_IS_WARNING_ENABLED());
    LOG_WARNING("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("WARN", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;33mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
    log(g_logger, log_level::warning, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("WARN", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;33mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
}

TEST_F(facter_logging, error) {
    ASSERT_EQ(true, LOG_IS_ERROR_ENABLED());
    LOG_ERROR("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("ERROR", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;31mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
    log(g_logger, log_level::error, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("ERROR", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;31mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
}

TEST_F(facter_logging, fatal) {
    ASSERT_EQ(true, LOG_IS_FATAL_ENABLED());
    LOG_FATAL("testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("FATAL", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;31mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
    log(g_logger, log_level::fatal, "testing %1% %2% %3%", 1, "2", 3.0);
    ASSERT_EQ("FATAL", _appender->last_level());
    ASSERT_EQ(g_color ? "\x1B[0;31mtesting 1 2 3\x1B[0m" : "testing 1 2 3", _appender->last_message());
}
