#include <gmock/gmock.h>
#include <log4cxx/logger.h>
#include <log4cxx/propertyconfigurator.h>
#include <log4cxx/patternlayout.h>
#include <log4cxx/consoleappender.h>

using namespace std;
using namespace log4cxx;

struct Environment : testing::Environment
{
    virtual void SetUp()
    {
        // Setup log4cxx
        LayoutPtr layout = new PatternLayout("%d %-5p %c - %m%n");
        AppenderPtr appender = new ConsoleAppender(layout);
        Logger::getRootLogger()->addAppender(appender);

        // To change logging output, set this to your desired level
        Logger::getRootLogger()->setLevel(Level::getWarn());
    }

    virtual void TearDown()
    {
    }
};

static ::testing::Environment* const env = ::testing::AddGlobalTestEnvironment(new Environment());
