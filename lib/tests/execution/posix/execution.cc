#include <gmock/gmock.h>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>
#include "../../fixtures.hpp"
#include <stdlib.h>

using namespace std;
using namespace facter::util;
using namespace facter::execution;
using namespace facter::testing;

TEST(execution_posix, simple_execution) {
    string output = execute("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file3.txt" });
    ASSERT_EQ("file3", output);
}

TEST(execution_posix, simple_execution_with_args) {
    string output = execute("ls", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls" });
    ASSERT_EQ("file1.txt\nfile2.txt\nfile3.txt\nfile4.txt", output);
}

TEST(execution_posix, stderr_redirection) {
    // By default, we don't return stderr
    string output = execute("ls", { "does_not_exist" });
    ASSERT_EQ("", output);

    output = execute("ls", { "does_not_exist" }, option_set<execution_options>({ execution_options::defaults, execution_options::redirect_stderr }));
    ASSERT_TRUE(ends_with(output, "No such file or directory"));
}

TEST(execution_posix, throw_on_nonzero_exit) {
    // By default, we don't throw an exception
    string output = execute("ls", { "does_not_exist" });
    ASSERT_EQ("", output);

    ASSERT_THROW(execute("ls", { "does_not_exist" }, option_set<execution_options>({ execution_options::defaults, execution_options::throw_on_nonzero_exit })), child_exit_exception);
}

TEST(execution_posix, throw_on_signal) {
    // By default, we don't throw an exception
    string output = execute("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/selfkill.sh" });
    ASSERT_EQ("", output);

    ASSERT_THROW(execute("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/selfkill.sh" },  option_set<execution_options>({ execution_options::defaults, execution_options::throw_on_signal })), child_signal_exception);
}

TEST(execution_posix, trim_output) {
    // We should trim output by default
    string output = execute("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt" });
    ASSERT_EQ("this is a test of trimming", output);

    // Now try again without any execution options
    option_set<execution_options> options = { execution_options::defaults };
    options.clear(execution_options::trim_output);
    output = execute("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt" }, options);
    ASSERT_EQ("   this is a test of trimming   ", output);
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
    string output = execute("env", {}, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    });
    unsetenv("TEST_INHERITED_VARIABLE");
    map<string, string> variables;
    facter::util::each_line(output, [&](string& line) {
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
    string output = execute("env", {}, {
        {"TEST_VARIABLE1", "TEST_VALUE1" },
        {"TEST_VARIABLE2", "TEST_VALUE2" }
    }, options);
    unsetenv("TEST_INHERITED_VARIABLE");
    map<string, string> variables;
    facter::util::each_line(output, [&](string& line) {
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
    string output = execute("env", {}, { {"LANG", "FOO" }, { "LC_ALL", "BAR" } });
    map<string, string> variables;
    facter::util::each_line(output, [&](string& line) {
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
