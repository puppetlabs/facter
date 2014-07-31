#include <gmock/gmock.h>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>
#include "../../fixtures.hpp"
#include <stdlib.h>

using namespace std;
using namespace facter::util;
using namespace facter::execution;
using namespace facter::testing;

TEST(execution_posix, which_absolute) {
    ASSERT_EQ(
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts",
        which(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts"));
}

TEST(execution_posix, which) {
    ASSERT_EQ(
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts",
        which("facts", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }));
}

TEST(execution_posix, which_partial) {
    ASSERT_EQ(
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts",
        which("posix/execution/facts", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external" }));
}

TEST(execution_posix, which_not_found) {
    ASSERT_EQ("", which("not_on_the_path"));
}

TEST(execution_posix, which_not_executable) {
    ASSERT_EQ(
        "",
        which("not_executable", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }));
}

TEST(execution_posix, expand_command) {
    ASSERT_EQ(
        LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts 1 2 3",
        expand_command("facts 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }));
}

TEST(execution_posix, expand_command_single_quote) {
    ASSERT_EQ(
        "'" LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts' 1 2 3",
        expand_command("'facts' 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }));
}

TEST(execution_posix, expand_command_double_quote) {
    ASSERT_EQ(
        "\"" LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts\" 1 2 3",
        expand_command("\"facts\" 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }));
}

TEST(execution_posix, expand_command_not_found) {
    ASSERT_EQ("not_on_the_path", expand_command("not_on_the_path"));
}

TEST(execution_posix, expand_command_not_executable) {
    ASSERT_EQ(
        "not_executable",
        expand_command("not_executable", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }));
}

TEST(execution_posix, simple_execution) {
    auto result = execute("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file3.txt" });
    ASSERT_TRUE(result.first);
    ASSERT_EQ("file3", result.second);
}

TEST(execution_posix, simple_execution_with_args) {
    auto result = execute("ls", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls" });
    ASSERT_TRUE(result.first);
    ASSERT_EQ("file1.txt\nfile2.txt\nfile3.txt\nfile4.txt", result.second);
}

TEST(execution_posix, stderr_redirection) {
    // By default, we don't return stderr
    auto result = execute("ls", { "does_not_exist" });
    ASSERT_FALSE(result.first);
    ASSERT_EQ("", result.second);

    result = execute("ls", { "does_not_exist" }, option_set<execution_options>({ execution_options::defaults, execution_options::redirect_stderr }));
    ASSERT_FALSE(result.first);
    ASSERT_TRUE(ends_with(result.second, "No such file or directory"));
}

TEST(execution_posix, throw_on_nonzero_exit) {
    // By default, we don't throw an exception
    auto result = execute("ls", { "does_not_exist" });
    ASSERT_FALSE(result.first);
    ASSERT_EQ("", result.second);

    ASSERT_THROW(execute("ls", { "does_not_exist" }, option_set<execution_options>({ execution_options::defaults, execution_options::throw_on_nonzero_exit })), child_exit_exception);
}

TEST(execution_posix, throw_on_signal) {
    // By default, we don't throw an exception
    auto result = execute("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/selfkill.sh" });
    ASSERT_FALSE(result.first);
    ASSERT_EQ("", result.second);

    ASSERT_THROW(execute("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/selfkill.sh" },  option_set<execution_options>({ execution_options::defaults, execution_options::throw_on_signal })), child_signal_exception);
}

TEST(execution_posix, trim_output) {
    // We should trim output by default
    auto result = execute("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt" });
    ASSERT_TRUE(result.first);
    ASSERT_EQ("this is a test of trimming", result.second);

    // Now try again without any execution options
    option_set<execution_options> options = { execution_options::defaults };
    options.clear(execution_options::trim_output);
    result = execute("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt" }, options);
    ASSERT_TRUE(result.first);
    ASSERT_EQ("   this is a test of trimming   ", result.second);
}

TEST(execution_posix, each_line) {
    size_t count = 0;
    bool failed = false;
    each_line("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file4.txt" }, [&](string& line) {
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
    each_line("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file4.txt" }, [&](string& line) {
        failed = line != "line1";
        ++count;
        return false;
    });
    ASSERT_FALSE(failed);
    ASSERT_EQ(1u, count);
}

TEST(execution_posix, execute_with_merged_environment) {
    setenv("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE", 1);
    auto result = execute("env", {}, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    });
    ASSERT_TRUE(result.first);
    unsetenv("TEST_INHERITED_VARIABLE");
    map<string, string> variables;
    facter::util::each_line(result.second, [&](string& line) {
        auto parts = split(line, '=', false);
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

TEST(execution_posix, execute_with_specified_environment) {
    option_set<execution_options> options = { execution_options::defaults };
    options.clear(execution_options::merge_environment);

    setenv("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE", 1);
    auto result = execute("env", {}, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    }, options);
    ASSERT_TRUE(result.first);
    unsetenv("TEST_INHERITED_VARIABLE");
    map<string, string> variables;
    facter::util::each_line(result.second, [&](string& line) {
        auto parts = split(line, '=', false);
        if (parts.size() != 2) {
            return true;
        }
        variables.emplace(make_pair(move(parts[0]), move(parts[1])));
        return true;
    });
    ASSERT_EQ(4u, variables.size());
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

TEST(execution_posix, execute_with_lang_environment) {
    auto result = execute("env", {}, { {"LANG", "FOO" }, { "LC_ALL", "BAR" } });
    ASSERT_TRUE(result.first);
    map<string, string> variables;
    facter::util::each_line(result.second, [&](string& line) {
        auto parts = split(line, '=', false);
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

TEST(execution_posix, each_line_with_merged_environment) {
    map<string, string> variables;
    setenv("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE", 1);
    each_line("env", {}, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    }, [&](string& line) {
        auto parts = split(line, '=', false);
        if (parts.size() != 2) {
            return true;
        }
        variables.emplace(make_pair(move(parts[0]), move(parts[1])));
        return true;
    });
    unsetenv("TEST_INHERITED_VARIABLE");
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

TEST(execution_posix, each_line_with_specified_environment) {
    map<string, string> variables;
    option_set<execution_options> options = { execution_options::defaults };
    options.clear(execution_options::merge_environment);
    setenv("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE", 1);
    each_line("env", {}, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    }, [&](string& line) {
        auto parts = split(line, '=', false);
        if (parts.size() != 2) {
            return true;
        }
        variables.emplace(make_pair(move(parts[0]), move(parts[1])));
        return true;
    }, options);
    unsetenv("TEST_INHERITED_VARIABLE");
    ASSERT_EQ(4u, variables.size());
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

TEST(execution_posix, each_line_with_lang_environment) {
    map<string, string> variables;
    each_line("env", {}, { {"LANG", "FOO" }, { "LC_ALL", "BAR" } }, [&](string& line) {
        auto parts = split(line, '=', false);
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
