#include <gmock/gmock.h>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>
#include "../../fixtures.hpp"

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
    ASSERT_EQ("file1.txt\nfile2.txt\nfile3.txt", output);
}

TEST(execution_posix, stderr_redirection) {
    // By default, we don't return stderr
    string output = execute("ls", { "does_not_exist" });
    ASSERT_EQ("", output);

    output = execute("ls", { "does_not_exist" }, { execution_options::defaults, execution_options::redirect_stderr });
    ASSERT_TRUE(ends_with(output, "No such file or directory"));
}

TEST(execution_posix, throw_on_nonzero_exit) {
    // By default, we don't throw an exception
    string output = execute("ls", { "does_not_exist" });
    ASSERT_EQ("", output);

    ASSERT_THROW(execute("ls", { "does_not_exist" }, { execution_options::defaults, execution_options::throw_on_nonzero_exit }), child_exit_exception);
}

TEST(execution_posix, throw_on_signal) {
    // By default, we don't throw an exception
    string output = execute("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/selfkill.sh" });
    ASSERT_EQ("", output);

    ASSERT_THROW(execute("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/selfkill.sh" }, { execution_options::defaults, execution_options::throw_on_signal }), child_signal_exception);
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
