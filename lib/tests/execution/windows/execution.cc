#include <gmock/gmock.h>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>
#include <facter/util/windows/windows.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include "../../fixtures.hpp"
#include <stdlib.h>

using namespace std;
using namespace facter::util;
using namespace facter::execution;
using namespace facter::testing;
using namespace boost::filesystem;

// Ruby doesn't appear to normalize commands passed to cmd.exe, so neither do we. A utility is provided
// here for familiarity in writing unit tests.
static string normalize(const char *filepath)
{
    return path(filepath).make_preferred().string();
}

TEST(execution_windows, which_absolute) {
    ASSERT_EQ(
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/facts.bat",
        which(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/facts.bat"));
}

TEST(execution_windows, which) {
    ASSERT_EQ(
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution\\facts.bat",
        which("facts", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }));
}

TEST(execution_windows, which_partial) {
    ASSERT_EQ(
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external\\windows/execution/facts.bat",
        which("windows/execution/facts", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external" }));
}

TEST(execution_windows, which_not_found) {
    ASSERT_EQ("", which("not_on_the_path"));
}

TEST(execution_windows, which_not_executable) {
    ASSERT_EQ(
        "",
        which("not_executable", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }));
}

TEST(execution_windows, expand_command) {
    ASSERT_EQ(
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution\\facts.bat 1 2 3",
        expand_command("facts 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }));
}

TEST(execution_windows, expand_command_single_quote) {
    ASSERT_EQ(
        "'" LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution\\facts.bat' 1 2 3",
        expand_command("'facts' 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }));
}

TEST(execution_windows, expand_command_double_quote) {
    ASSERT_EQ(
        "\"" LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution\\facts.bat\" 1 2 3",
        expand_command("\"facts\" 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }));
}

TEST(execution_windows, expand_command_not_found) {
    ASSERT_EQ("not_on_the_path", expand_command("not_on_the_path"));
}

TEST(execution_windows, expand_command_not_executable) {
    ASSERT_EQ(
        "not_executable",
        expand_command("not_executable", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }));
}

TEST(execution_windows, simple_execution) {
    auto result = execute("cmd.exe", { "/c type", normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file3.txt") });
    ASSERT_TRUE(result.first);
    ASSERT_EQ("file3", result.second);
}

TEST(execution_windows, simple_execution_with_args) {
    auto result = execute("cmd.exe", { "/c dir /B", normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls") });
    ASSERT_TRUE(result.first);
    ASSERT_EQ("file1.txt\r\nfile2.txt\r\nfile3.txt\r\nfile4.txt", result.second);
}

TEST(execution_windows, stderr_redirection) {
    // By default, we don't return stderr
    auto result = execute("cmd.exe", { "/c dir /B does_not_exist" });
    ASSERT_FALSE(result.first);
    ASSERT_EQ("", result.second);

    result = execute("cmd.exe", { "/c dir /B does_not_exist" },
        option_set<execution_options>({ execution_options::defaults, execution_options::redirect_stderr }));
    ASSERT_FALSE(result.first);
    ASSERT_EQ(result.second, "File Not Found");
}

TEST(execution_windows, throw_on_nonzero_exit) {
    // By default, we don't throw an exception
    auto result = execute("cmd.exe", { "/c dir /B does_not_exist" });
    ASSERT_FALSE(result.first);
    ASSERT_EQ("", result.second);

    ASSERT_THROW(execute("cmd.exe", { "/c dir /B does_not_exist" },
        option_set<execution_options>({ execution_options::defaults, execution_options::throw_on_nonzero_exit })), child_exit_exception);
}

TEST(execution_windows, trim_output) {
    // We should trim output by default
    auto result = execute("cmd.exe", { "/c type", normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt") });
    ASSERT_TRUE(result.first);
    ASSERT_EQ("this is a test of trimming", result.second);

    // Now try again without any execution options
    option_set<execution_options> options = { execution_options::defaults };
    options.clear(execution_options::trim_output);
    result = execute("cmd.exe", { "/c type", normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt") }, options);
    ASSERT_TRUE(result.first);
    ASSERT_EQ("   this is a test of trimming   ", result.second);
}

TEST(execution_windows, each_line) {
    size_t count = 0;
    bool failed = false;
    each_line("cmd.exe", { "/c type", normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file4.txt") }, [&](string& line) {
        if ((count == 0 && line != "line1") ||
            (count == 1 && line != "line2") ||
            (count == 2 && line != "line3") ||
            (count == 3 && line != "line4")) {
            failed = true;
            return false;
        }
        ++count;
        return true;
    });
    ASSERT_FALSE(failed);
    ASSERT_EQ(4u, count);

     // Test short-circuiting
    count = 0;
    each_line("cmd.exe", { "/c type", normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file4.txt") }, [&](string& line) {
        failed = line != "line1";
        ++count;
        return false;
    });
    ASSERT_FALSE(failed);
    ASSERT_EQ(1u, count);
}

TEST(execution_windows, execute_with_merged_environment) {
    SetEnvironmentVariable("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE");
    auto result = execute("cmd.exe", { "/c set" }, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    });
    ASSERT_TRUE(result.first);
    SetEnvironmentVariable("TEST_INHERITED_VARIABLE", nullptr);
    map<string, string> variables;
    facter::util::each_line(result.second, [&](string& line) {
        vector<string> parts;
        boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
        if (parts.size() != 2) {
            return true;
        }
        variables.emplace(make_pair(move(parts[0]), move(parts[1])));
        return true;
    });
    ASSERT_EQ(1u, variables.count("TEST_VARIABLE1"));
    ASSERT_EQ("TEST_VALUE1", variables["TEST_VARIABLE1"]);
    ASSERT_EQ(1u, variables.count("TEST_VARIABLE2"));
    ASSERT_EQ("TEST_VALUE2", variables["TEST_VARIABLE2"]);
    ASSERT_EQ(1u, variables.count("TEST_INHERITED_VARIABLE"));
    ASSERT_EQ("TEST_INHERITED_VALUE", variables["TEST_INHERITED_VARIABLE"]);
    ASSERT_EQ(1u, variables.count("LANG"));
    ASSERT_EQ("C", variables["LANG"]);
    ASSERT_EQ(1u, variables.count("LC_ALL"));
    ASSERT_EQ("C", variables["LC_ALL"]);
}

TEST(execution_windows, execute_with_specified_environment) {
    option_set<execution_options> options = { execution_options::defaults };
    options.clear(execution_options::merge_environment);

    SetEnvironmentVariable("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE");
    auto result = execute("cmd.exe", { "/c set" }, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    }, options);
    ASSERT_TRUE(result.first);
    SetEnvironmentVariable("TEST_INHERITED_VARIABLE", nullptr);
    map<string, string> variables;
    facter::util::each_line(result.second, [&](string& line) {
        vector<string> parts;
        boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
        if (parts.size() != 2) {
            return true;
        }
        variables.emplace(make_pair(move(parts[0]), move(parts[1])));
        return true;
    });
    // Windows cmd.exe adds 3 extra environment variables on startup: COMSPEC, PATHEXT, and PROMPT.
    // I'm not aware of another simple way to print the startup environment.
    ASSERT_EQ(7u, variables.size());
    ASSERT_EQ(1u, variables.count("TEST_VARIABLE1"));
    ASSERT_EQ("TEST_VALUE1", variables["TEST_VARIABLE1"]);
    ASSERT_EQ(1u, variables.count("TEST_VARIABLE2"));
    ASSERT_EQ("TEST_VALUE2", variables["TEST_VARIABLE2"]);
    ASSERT_EQ(0u, variables.count("TEST_INHERITED_VARIABLE"));
    ASSERT_EQ(1u, variables.count("LANG"));
    ASSERT_EQ("C", variables["LANG"]);
    ASSERT_EQ(1u, variables.count("LC_ALL"));
    ASSERT_EQ("C", variables["LC_ALL"]);
}

TEST(execution_windows, execute_with_lang_environment) {
    auto result = execute("cmd.exe", { "/c set" }, { {"LANG", "FOO" }, { "LC_ALL", "BAR" } });
    ASSERT_TRUE(result.first);
    map<string, string> variables;
    facter::util::each_line(result.second, [&](string& line) {
        vector<string> parts;
        boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
        if (parts.size() != 2) {
            return true;
        }
        variables.emplace(make_pair(move(parts[0]), move(parts[1])));
        return true;
    });
    ASSERT_EQ(1u, variables.count("LANG"));
    ASSERT_EQ("FOO", variables["LANG"]);
    ASSERT_EQ(1u, variables.count("LC_ALL"));
    ASSERT_EQ("BAR", variables["LC_ALL"]);
}

TEST(execution_windows, each_line_with_merged_environment) {
    map<string, string> variables;
    SetEnvironmentVariable("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE");
    each_line("cmd.exe", { "/c set" }, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    }, [&](string& line) {
        vector<string> parts;
        boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
        if (parts.size() != 2) {
            return true;
        }
        variables.emplace(make_pair(move(parts[0]), move(parts[1])));
        return true;
    });
    SetEnvironmentVariable("TEST_INHERITED_VARIABLE", nullptr);
    ASSERT_EQ(1u, variables.count("TEST_VARIABLE1"));
    ASSERT_EQ("TEST_VALUE1", variables["TEST_VARIABLE1"]);
    ASSERT_EQ(1u, variables.count("TEST_VARIABLE2"));
    ASSERT_EQ("TEST_VALUE2", variables["TEST_VARIABLE2"]);
    ASSERT_EQ(1u, variables.count("TEST_INHERITED_VARIABLE"));
    ASSERT_EQ("TEST_INHERITED_VALUE", variables["TEST_INHERITED_VARIABLE"]);
    ASSERT_EQ(1u, variables.count("LANG"));
    ASSERT_EQ("C", variables["LANG"]);
    ASSERT_EQ(1u, variables.count("LC_ALL"));
    ASSERT_EQ("C", variables["LC_ALL"]);
}

TEST(execution_windows, each_line_with_specified_environment) {
    map<string, string> variables;
    option_set<execution_options> options = { execution_options::defaults };
    options.clear(execution_options::merge_environment);
    SetEnvironmentVariable("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE");
    each_line("cmd.exe", { "/c set" }, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    }, [&](string& line) {
        vector<string> parts;
        boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
        if (parts.size() != 2) {
            return true;
        }
        variables.emplace(make_pair(move(parts[0]), move(parts[1])));
        return true;
    }, options);
    SetEnvironmentVariable("TEST_INHERITED_VARIABLE", nullptr);
    // Windows cmd.exe adds 3 extra environment variables on startup: COMSPEC, PATHEXT, and PROMPT.
    // I'm not aware of another simple way to print the startup environment.
    ASSERT_EQ(7u, variables.size());
    ASSERT_EQ(1u, variables.count("TEST_VARIABLE1"));
    ASSERT_EQ("TEST_VALUE1", variables["TEST_VARIABLE1"]);
    ASSERT_EQ(1u, variables.count("TEST_VARIABLE2"));
    ASSERT_EQ("TEST_VALUE2", variables["TEST_VARIABLE2"]);
    ASSERT_EQ(0u, variables.count("TEST_INHERITED_VARIABLE"));
    ASSERT_EQ(1u, variables.count("LANG"));
    ASSERT_EQ("C", variables["LANG"]);
    ASSERT_EQ(1u, variables.count("LC_ALL"));
    ASSERT_EQ("C", variables["LC_ALL"]);
}

TEST(execution_windows, each_line_with_lang_environment) {
    map<string, string> variables;
    each_line("cmd.exe", { "/c set" }, { {"LANG", "FOO" }, { "LC_ALL", "BAR" } }, [&](string& line) {
        vector<string> parts;
        boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
        if (parts.size() != 2) {
            return true;
        }
        variables.emplace(make_pair(move(parts[0]), move(parts[1])));
        return true;
    });
    ASSERT_EQ(1u, variables.count("LANG"));
    ASSERT_EQ("FOO", variables["LANG"]);
    ASSERT_EQ(1u, variables.count("LC_ALL"));
    ASSERT_EQ("BAR", variables["LC_ALL"]);
}
