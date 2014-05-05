#include <gmock/gmock.h>
#include <facter/logging/logging.hpp>
#include <log4cxx/logger.h>
#include <log4cxx/propertyconfigurator.h>
#include <log4cxx/patternlayout.h>
#include <log4cxx/consoleappender.h>

using namespace std;
using namespace facter::logging;
using namespace log4cxx;

LOG_DECLARE_NAMESPACE("logging.test");

bool g_color = isatty(fileno(stdout));

struct custom_log_appender : AppenderSkeleton
{
 public:
    DECLARE_LOG4CXX_OBJECT(custom_log_appender)
    BEGIN_LOG4CXX_CAST_MAP()
        LOG4CXX_CAST_ENTRY(custom_log_appender)
        LOG4CXX_CAST_ENTRY_CHAIN(AppenderSkeleton)
    END_LOG4CXX_CAST_MAP()

    void append(const spi::LoggingEventPtr& event, log4cxx::helpers::Pool& p)
    {
        _level = event->getLevel()->toString();
        _message = event->getMessage();
    }

    void close() {}
    bool requiresLayout() const { return false; }

    string const& last_level() const { return _level; }
    string const& last_message() const { return _message; }

 private:
     string _level;
     string _message;
};

IMPLEMENT_LOG4CXX_OBJECT(custom_log_appender);

struct facter_logging : ::testing::Test {
 protected:
    virtual void SetUp()
    {
        auto root = Logger::getRootLogger();

        _level = root->getLevel();
        root->setLevel(Level::getDebug());

        _appenders = root->getAllAppenders();
        root->removeAllAppenders();

        _appender = new custom_log_appender();
        root->addAppender(_appender);
    }

    virtual void TearDown()
    {
        auto root = Logger::getRootLogger();

        Logger::getRootLogger()->setLevel(_level);

        root->removeAllAppenders();
        for (auto const& appender : _appenders) {
            root->addAppender(appender);
        }
    }

    custom_log_appender* _appender;
    AppenderList _appenders;
    LevelPtr _level;
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
