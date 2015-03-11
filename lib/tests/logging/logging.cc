#include <catch.hpp>
#include <facter/logging/logging.hpp>
#include <leatherman/logging/logging.hpp>
#include <boost/log/sinks/sync_frontend.hpp>
#include <boost/log/sinks/basic_sink_backend.hpp>
#include <boost/nowide/convert.hpp>

using namespace std;
using namespace facter::logging;
namespace sinks = boost::log::sinks;

struct custom_log_appender :
    sinks::basic_formatted_sink_backend<char, sinks::synchronized_feeding>
{
    void consume(boost::log::record_view const& rec, string_type const& message)
    {
        stringstream s;
        for (auto const& attr : rec.attribute_values()) {
            if (attr.first == "Severity") {
                s << attr.second.extract<leatherman::logging::log_level>();
            }
        }
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
        set_level(level::trace);
        clear_logged_errors();

        _appender.reset(new custom_log_appender());
        _sink.reset(new sink_t(_appender));

        auto core = boost::log::core::get();
        core->add_sink(_sink);
    }

    ~logging_test_context()
    {
        set_level(level::none);
        clear_logged_errors();

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
    REQUIRE(is_enabled(level::trace));
    log(level::trace, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "TRACE");
    REQUIRE(context._appender->_message == string(colorize(level::trace)) + "testing 1 2 3" + colorize());
    REQUIRE_FALSE(error_logged());
}

SCENARIO("logging with a DEBUG level") {
    logging_test_context context;
    REQUIRE(is_enabled(level::debug));
    log(level::debug, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "DEBUG");
    REQUIRE(context._appender->_message == string(colorize(level::debug)) + "testing 1 2 3" + colorize());
    REQUIRE_FALSE(error_logged());
}

SCENARIO("logging with an INFO level") {
    logging_test_context context;
    REQUIRE(is_enabled(level::info));
    log(level::info, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "INFO");
    REQUIRE(context._appender->_message == string(colorize(level::info)) + "testing 1 2 3" + colorize());
    REQUIRE_FALSE(error_logged());
}

SCENARIO("logging with a WARNING level") {
    logging_test_context context;
    REQUIRE(is_enabled(level::warning));
    log(level::warning, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "WARN");
    REQUIRE(context._appender->_message == string(colorize(level::warning)) + "testing 1 2 3" + colorize());
    REQUIRE_FALSE(error_logged());
}

SCENARIO("logging with an ERROR level") {
    logging_test_context context;
    REQUIRE(is_enabled(level::error));
    log(level::error, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "ERROR");
    REQUIRE(context._appender->_message == string(colorize(level::error)) + "testing 1 2 3" + colorize());
    REQUIRE(error_logged());
}

SCENARIO("logging with a FATAL level") {
    logging_test_context context;
    REQUIRE(is_enabled(level::fatal));
    log(level::fatal, "testing %1% %2% %3%", 1, "2", 3.0);
    REQUIRE(context._appender->_level == "FATAL");
    REQUIRE(context._appender->_message == string(colorize(level::fatal)) + "testing 1 2 3" + colorize());
    REQUIRE(error_logged());
}
