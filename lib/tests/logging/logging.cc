#include <catch.hpp>
#include <facter/logging/logging.hpp>
#include <boost/log/sinks/sync_frontend.hpp>
#include <boost/log/sinks/basic_sink_backend.hpp>
#include <boost/nowide/convert.hpp>
#include <boost/nowide/iostream.hpp>

using namespace std;
using namespace facter::logging;
namespace sinks = boost::log::sinks;

struct custom_log_appender :
    sinks::basic_formatted_sink_backend<char, sinks::synchronized_feeding>
{
    void consume(boost::log::record_view const& rec, string_type const& message)
    {
        stringstream s;
        s << rec[log_level_attr];
        _level = s.str();
        _message = message;
    }

    string _level;
    string _message;
};

struct logging_test_context
{
    using sink_t = sinks::synchronous_sink<custom_log_appender>;

    logging_test_context()
    {
        set_level(log_level::trace);
        _appender.reset(new custom_log_appender());
        _sink.reset(new sink_t(_appender));

        auto core = boost::log::core::get();
        core->add_sink(_sink);
    }

    ~logging_test_context()
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
};

SCENARIO("logging with a TRACE level") {
    logging_test_context context;
    REQUIRE(LOG_IS_TRACE_ENABLED());
    LOG_TRACE("testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "TRACE");
    REQUIRE(context._appender->_message == string(colorize(log_level::trace)) + "testing 1 2 3" + colorize());
    log("test", log_level::trace, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "TRACE");
    REQUIRE(context._appender->_message == string(colorize(log_level::trace)) + "testing 1 2 3" + colorize());
}

SCENARIO("logging with a DEBUG level") {
    logging_test_context context;
    REQUIRE(LOG_IS_DEBUG_ENABLED());
    LOG_DEBUG("testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "DEBUG");
    REQUIRE(context._appender->_message == string(colorize(log_level::debug)) + "testing 1 2 3" + colorize());
    log("test", log_level::debug, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "DEBUG");
    REQUIRE(context._appender->_message == string(colorize(log_level::debug)) + "testing 1 2 3" + colorize());
}

SCENARIO("logging with an INFO level") {
    logging_test_context context;
    REQUIRE(LOG_IS_INFO_ENABLED());
    LOG_INFO("testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "INFO");
    REQUIRE(context._appender->_message == string(colorize(log_level::info)) + "testing 1 2 3" + colorize());
    log("test", log_level::info, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "INFO");
    REQUIRE(context._appender->_message == string(colorize(log_level::info)) + "testing 1 2 3" + colorize());
}

SCENARIO("logging with a WARNING level") {
    logging_test_context context;
    REQUIRE(LOG_IS_WARNING_ENABLED());
    LOG_WARNING("testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "WARN");
    REQUIRE(context._appender->_message == string(colorize(log_level::warning)) + "testing 1 2 3" + colorize());
    log("test", log_level::warning, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "WARN");
    REQUIRE(context._appender->_message == string(colorize(log_level::warning)) + "testing 1 2 3" + colorize());
}

SCENARIO("logging with an ERROR level") {
    logging_test_context context;
    REQUIRE(LOG_IS_ERROR_ENABLED());
    LOG_ERROR("testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "ERROR");
    REQUIRE(context._appender->_message == string(colorize(log_level::error)) + "testing 1 2 3" + colorize());
    log("test", log_level::error, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "ERROR");
    REQUIRE(context._appender->_message == string(colorize(log_level::error)) + "testing 1 2 3" + colorize());
}

SCENARIO("logging with a FATAL level") {
    logging_test_context context;
    REQUIRE(LOG_IS_FATAL_ENABLED());
    LOG_FATAL("testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "FATAL");
    REQUIRE(context._appender->_message == string(colorize(log_level::fatal)) + "testing 1 2 3" + colorize());
    log("test", log_level::fatal, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "FATAL");
    REQUIRE(context._appender->_message == string(colorize(log_level::fatal)) + "testing 1 2 3" + colorize());
}

SCENARIO("logging with on_message") {
    logging_test_context context;
    string message;
    log_level level;
    on_message([&](log_level lvl, string const& msg) {
        level = lvl;
        message = msg;
        return false;
    });
    GIVEN("a TRACE message to log") {
        LOG_TRACE("trace message");
        THEN("on_message is called with the message") {
            REQUIRE(level == log_level::trace);
            REQUIRE(message == "trace message");
        }
    }
    GIVEN("a DEBUG message to log") {
        LOG_DEBUG("debug message");
        THEN("on_message is called with the message") {
            REQUIRE(level == log_level::debug);
            REQUIRE(message == "debug message");
        }
    }
    GIVEN("a INFO message to log") {
        LOG_INFO("info message");
        THEN("on_message is called with the message") {
            REQUIRE(level == log_level::info);
            REQUIRE(message == "info message");
        }
    }
    GIVEN("a WARNING message to log") {
        LOG_WARNING("warning message");
        THEN("on_message is called with the message") {
            REQUIRE(level == log_level::warning);
            REQUIRE(message == "warning message");
        }
    }
    GIVEN("a ERROR message to log") {
        LOG_ERROR("error message");
        THEN("on_message is called with the message") {
            REQUIRE(level == log_level::error);
            REQUIRE(message == "error message");
        }
    }
    GIVEN("a FATAL message to log") {
        LOG_FATAL("fatal message");
        THEN("on_message is called with the message") {
            REQUIRE(level == log_level::fatal);
            REQUIRE(message == "fatal message");
        }
    }
    GIVEN("a unicode characters to log") {
        const wstring symbols[] = {L"\u2122", L"\u2744", L"\u039b"};
        for (auto const& s : symbols) {
            auto utf8 = boost::nowide::narrow(s);
            LOG_INFO(utf8);
            REQUIRE(level == log_level::info);
            REQUIRE(message == utf8);
        }
    }
}
