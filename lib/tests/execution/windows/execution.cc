#include <catch.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>
#include <internal/util/windows/windows.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <internal/util/regex.hpp>
#include "../../fixtures.hpp"
#include "../../log_capture.hpp"
#include <stdlib.h>

using namespace std;
using namespace facter::util;
using namespace facter::execution;
using namespace facter::logging;
using namespace facter::testing;
using namespace boost::filesystem;

// Ruby doesn't appear to normalize commands passed to cmd.exe, so neither do we. A utility is provided
// here for familiarity in writing unit tests.
static string normalize(const char *filepath)
{
    return path(filepath).make_preferred().string();
}

SCENARIO("searching for programs with execution::which") {
    GIVEN("an absolute path") {
        THEN("the same path should be returned") {
            REQUIRE(which(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/facts.bat") == LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/facts.bat");
        }
    }
    GIVEN("a relative path") {
        THEN("it should find a file with the same relative offset from a directory on PATH") {
            REQUIRE(which("windows/execution/facts", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external" }) == LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external\\windows/execution/facts.bat");
        }
    }
    GIVEN("a file without an extension") {
        THEN("it should find a batch file with the same base name") {
            REQUIRE(which("facts", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }) == LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution\\facts.bat");
        }
    }
    GIVEN("a file that does not exist") {
        THEN("an empty string should be returned") {
            REQUIRE(which("not_on_the_path") == "");
        }
    }
     GIVEN("a file that exists but is not an executable") {
        THEN("an empty string should be returned") {
            REQUIRE(which("not_executable", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }) == "");
        }
    }
}

SCENARIO("expanding command paths with execution::expand_command") {
    GIVEN("an executable on the PATH") {
        THEN("the executable is expanded to an absolute path") {
            REQUIRE(expand_command("facts 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }) == LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution\\facts.bat 1 2 3");
        }
    }
    GIVEN("a single-quoted command") {
        THEN("the expanded path should be single-quoted") {
            REQUIRE(expand_command("'facts' 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }) == "'" LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution\\facts.bat' 1 2 3");
        }
    }
    GIVEN("a double-quoted command") {
        THEN("the expanded path should be double-quoted") {
            REQUIRE(expand_command("\"facts\" 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }) == "\"" LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution\\facts.bat\" 1 2 3");
        }
    }
    GIVEN("a command not on PATH") {
        THEN("the returned command is empty") {
            REQUIRE(expand_command("not_on_the_path") == "");
        }
    }
    GIVEN("a non-executable command on PATH") {
        THEN("the returned command is empty") {
            REQUIRE(expand_command("not_executable", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution" }) == "");
        }
    }
}

SCENARIO("executing commands with execution::execute") {
    auto get_variables = [](string const& input) {
        map<string, string> variables;
        facter::util::each_line(input, [&](string& line) {
            vector<string> parts;
            boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
            if (parts.size() != 2u) {
                return true;
            }
            variables.emplace(make_pair(move(parts[0]), move(parts[1])));
            return true;
        });
        return variables;
    };
    bool success = false;
    string output, error;
    GIVEN("a command that succeeds") {
        THEN("the output should be returned") {
            tie(success, output, error) = execute("cmd.exe", { "/c", "type", normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file3.txt") });
            REQUIRE(success);
            REQUIRE(output == "file3");
            REQUIRE(error == "");
        }
    }
    GIVEN("a command that fails") {
        WHEN("default options are used") {
            tie(success, output, error) = execute("cmd.exe", { "/c", "dir", "/B", "does_not_exist" });
            THEN("no output is returned") {
                REQUIRE_FALSE(success);
                REQUIRE(output == "");
                REQUIRE(error == "");
            }
        }
        WHEN("the redirect stderr option is used") {
            tie(success, output, error) = execute("cmd.exe", { "/c", "dir", "/B", "does_not_exist" }, 0, { execution_options::trim_output, execution_options::merge_environment, execution_options::redirect_stderr_to_stdout });
            THEN("error output is returned on stdout") {
                REQUIRE_FALSE(success);
                REQUIRE(output == "File Not Found");
                REQUIRE(error == "");
            }
        }
        WHEN("not redirecting stderr to null") {
            tie(success, output, error) = execute("cmd.exe", { "/c", "dir", "/B", "does_not_exist" }, 0, { execution_options::trim_output, execution_options::merge_environment });
            THEN("error output is returned") {
                REQUIRE_FALSE(success);
                REQUIRE(output == "");
                REQUIRE(error == "File Not Found");
            }
        }
        WHEN("the 'throw on non-zero exit' option is used") {
            THEN("a child exit exception is thrown") {
                REQUIRE_THROWS_AS(execute("cmd.exe", { "/c", "dir", "/B", "does_not_exist" }, 0, { execution_options::trim_output, execution_options::merge_environment, execution_options::throw_on_nonzero_exit }), child_exit_exception);
            }
        }
        WHEN("requested to merge the environment") {
            SetEnvironmentVariableW(L"TEST_INHERITED_VARIABLE", L"TEST_INHERITED_VALUE");
            tie(success, output, error) = execute("cmd.exe", { "/c", "set" }, { { "TEST_VARIABLE1", "TEST_VALUE1" }, { "TEST_VARIABLE2", "TEST_VALUE2" } });
            SetEnvironmentVariableW(L"TEST_INHERITED_VARIABLE", nullptr);
            REQUIRE(success);
            REQUIRE(error == "");
            auto variables = get_variables(output);
            THEN("the child environment should contain the given variables") {
                REQUIRE(variables.size() > 4u);
                REQUIRE(variables.count("TEST_VARIABLE1") == 1u);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
                REQUIRE(variables.count("TEST_VARIABLE1") == 1u);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
            }
            THEN("the child environment should have LC_ALL and LANG set to C") {
                REQUIRE(variables.count("LC_ALL") == 1u);
                REQUIRE(variables["LC_ALL"] == "C");
                REQUIRE(variables.count("LANG") == 1u);
                REQUIRE(variables["LANG"] == "C");
            }
        }
        WHEN("requested to override the environment") {
            SetEnvironmentVariableW(L"TEST_INHERITED_VARIABLE", L"TEST_INHERITED_VALUE");
            tie(success, output, error) = execute("cmd.exe", { "/c", "set" }, { { "TEST_VARIABLE1", "TEST_VALUE1" }, { "TEST_VARIABLE2", "TEST_VALUE2" } }, 0, { execution_options::trim_output });
            SetEnvironmentVariableW(L"TEST_INHERITED_VARIABLE", nullptr);
            REQUIRE(success);
            REQUIRE(error == "");
            auto variables = get_variables(output);
            THEN("the child environment should only contain the given variables") {
                REQUIRE(variables.count("TEST_VARIABLE1") == 1u);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
                REQUIRE(variables.count("TEST_VARIABLE1") == 1u);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
            }
            THEN("the child environment should have LC_ALL and LANG set to C") {
                REQUIRE(variables.count("LC_ALL") == 1u);
                REQUIRE(variables["LC_ALL"] == "C");
                REQUIRE(variables.count("LANG") == 1u);
                REQUIRE(variables["LANG"] == "C");
            }
        }
        WHEN("requested to override LC_ALL or LANG") {
            tie(success, output, error) = execute("cmd.exe", { "/c", "set" }, { { "LANG", "FOO" }, { "LC_ALL", "BAR" } });
            REQUIRE(success);
            REQUIRE(error == "");
            auto variables = get_variables(output);
            THEN("the values should be passed to the child process") {
                REQUIRE(variables.count("LC_ALL") == 1u);
                REQUIRE(variables["LC_ALL"] == "BAR");
                REQUIRE(variables.count("LANG") == 1u);
                REQUIRE(variables["LANG"] == "FOO");
            }
        }
    }
    GIVEN("a command that outputs leading/trailing whitespace") {
        THEN("whitespace should be trimmed by default") {
            tie(success, output, error) = execute("cmd.exe", { "/c", "type", normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt") });
            REQUIRE(success);
            REQUIRE(output == "this is a test of trimming");
            REQUIRE(error == "");
        }
        WHEN("the 'trim whitespace' option is not used") {
            tie(success, output, error) = execute("cmd.exe", { "/c", "type", normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt") }, 0, { execution_options::merge_environment });
            REQUIRE(success);
            THEN("whitespace should not be trimmed") {
                REQUIRE(output == "   this is a test of trimming   ");
                REQUIRE(error == "");
            }
        }
    }
    GIVEN("a long-running command") {
        WHEN("given a timeout") {
            THEN("a timeout exception should be thrown") {
                string ruby = which("ruby.exe");
                if (ruby.empty()) {
                    WARN("skipping command timeout test because no ruby was found on the PATH.");
                    return;
                }

                try {
                    execute("cmd.exe", { "/c", "ruby.exe", "-e", "sleep 60" }, 1);
                    FAIL("did not throw timeout exception");
                } catch (timeout_exception const& ex) {
                    // Verify the process was killed
                    REQUIRE(OpenProcess(0, FALSE, ex.pid()) == nullptr);
                } catch (exception const&) {
                    FAIL("unexpected exception thrown");
                }
            }
        }
    }
    GIVEN("stderr is redirected to null") {
        WHEN("using a debug log level") {
            log_capture capture(level::debug);
            tie(success, output, error) = execute(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/error_message.bat");
            REQUIRE(success);
            REQUIRE(output == "foo=bar");
            REQUIRE(error.empty());
            THEN("stderr is logged") {
                auto output = capture.result();
                CAPTURE(output);
                REQUIRE(re_search(output, boost::regex("DEBUG !!! - error message!")));
            }
        }
        WHEN("not using a debug log level") {
            log_capture capture(level::warning);
            tie(success, output, error) = execute(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/error_message.bat");
            REQUIRE(success);
            REQUIRE(output == "foo=bar");
            REQUIRE(error.empty());
            THEN("stderr is not logged") {
                auto output = capture.result();
                CAPTURE(output);
                REQUIRE_FALSE(re_search(output, boost::regex("DEBUG !!! - error message!")));
            }
        }
    }
}

SCENARIO("executing commands with execution::each_line") {
    GIVEN("a command that succeeds") {
        THEN("each line of output should be returned") {
            vector<string> lines;
            bool success = each_line(
                "cmd.exe",
                {
                    "/c",
                    "type",
                    normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file4.txt")
                },
                [&](string& line) {
                    lines.push_back(line);
                    return true;
                });
            REQUIRE(success);
            REQUIRE(lines.size() == 4u);
            REQUIRE(lines[0] == "line1");
            REQUIRE(lines[1] == "line2");
            REQUIRE(lines[2] == "line3");
            REQUIRE(lines[3] == "line4");
        }
        WHEN("output stops when false is returned from callback") {
            vector<string> lines;
            bool success = each_line(
                "cmd.exe",
                {
                    "/c",
                    "type",
                    normalize(LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file4.txt")
                },
                [&](string& line) {
                    lines.push_back(line);
                    return false;
                });
            REQUIRE(success);
            REQUIRE(lines.size() == 1u);
            REQUIRE(lines[0] == "line1");
        }
        WHEN("requested to merge the environment") {
            SetEnvironmentVariableW(L"TEST_INHERITED_VARIABLE", L"TEST_INHERITED_VALUE");
            map<string, string> variables;
            bool success = each_line(
                "cmd.exe",
                {
                    "/c",
                    "set"
                },
                {
                    {"TEST_VARIABLE1", "TEST_VALUE1" },
                    {"TEST_VARIABLE2", "TEST_VALUE2" }
                },
                [&](string& line) {
                    vector<string> parts;
                    boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
                    if (parts.size() != 2u) {
                        return true;
                    }
                    variables.emplace(make_pair(move(parts[0]), move(parts[1])));
                    return true;
                });
            SetEnvironmentVariableW(L"TEST_INHERITED_VARIABLE", nullptr);
            REQUIRE(success);
            THEN("the child environment should contain the given variables") {
                REQUIRE(variables.size() > 4u);
                REQUIRE(variables.count("TEST_VARIABLE1") == 1u);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
                REQUIRE(variables.count("TEST_VARIABLE1") == 1u);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
            }
            THEN("the child environment should have LC_ALL and LANG set to C") {
                REQUIRE(variables.count("LC_ALL") == 1u);
                REQUIRE(variables["LC_ALL"] == "C");
                REQUIRE(variables.count("LANG") == 1u);
                REQUIRE(variables["LANG"] == "C");
            }
        }
        WHEN("requested to override the environment") {
            SetEnvironmentVariableW(L"TEST_INHERITED_VARIABLE", L"TEST_INHERITED_VALUE");
            map<string, string> variables;
            bool success = each_line(
                "cmd.exe",
                {
                    "/c",
                    "set"
                },
                {
                    {"TEST_VARIABLE1", "TEST_VALUE1" },
                    {"TEST_VARIABLE2", "TEST_VALUE2" }
                },
                [&](string& line) {
                    vector<string> parts;
                    boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
                    if (parts.size() != 2u) {
                        return true;
                    }
                    variables.emplace(make_pair(move(parts[0]), move(parts[1])));
                    return true;
                },
                nullptr,
                0,
                {
                    execution_options::trim_output
                });
            SetEnvironmentVariableW(L"TEST_INHERITED_VARIABLE", nullptr);
            REQUIRE(success);
            THEN("the child environment should only contain the given variables") {
                REQUIRE(variables.count("TEST_VARIABLE1") == 1u);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
                REQUIRE(variables.count("TEST_VARIABLE1") == 1u);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
            }
            THEN("the child environment should have LC_ALL and LANG set to C") {
                REQUIRE(variables.count("LC_ALL") == 1u);
                REQUIRE(variables["LC_ALL"] == "C");
                REQUIRE(variables.count("LANG") == 1u);
                REQUIRE(variables["LANG"] == "C");
            }
        }
        WHEN("requested to override LC_ALL or LANG") {
            map<string, string> variables;
            bool success = each_line(
                "cmd.exe",
                {
                    "/c",
                    "set"
                },
                {
                    {"LANG", "FOO" },
                    { "LC_ALL", "BAR" }
                },
                [&](string& line) {
                    vector<string> parts;
                    boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
                    if (parts.size() != 2u) {
                        return true;
                    }
                    variables.emplace(make_pair(move(parts[0]), move(parts[1])));
                    return true;
                });
            REQUIRE(success);
            THEN("the values should be passed to the child process") {
                REQUIRE(variables.count("LC_ALL") == 1u);
                REQUIRE(variables["LC_ALL"] == "BAR");
                REQUIRE(variables.count("LANG") == 1u);
                REQUIRE(variables["LANG"] == "FOO");
            }
        }
    }
    GIVEN("a command that fails") {
        WHEN("default options are used") {
            THEN("no output is returned") {
                auto success = each_line(
                    "cmd.exe",
                    {
                        "/c",
                        "dir",
                        "/B",
                        "does_not_exist"
                    },
                    [](string& line) {
                        FAIL("should not be called");
                        return true;
                    });
                REQUIRE_FALSE(success);
            }
        }
        WHEN("the redirect stderr option is used") {
            string output;
            auto result = each_line(
                "cmd.exe",
                {
                    "/c",
                    "dir",
                    "/B",
                    "does_not_exist"
                },
                [&](string& line) {
                    if (!output.empty()) {
                        output += "\n";
                    }
                    output += line;
                    return true;
                },
                [&](string&) {
                    FAIL("should not be called");
                    return true;
                },
                0,
                {
                    execution_options::trim_output,
                    execution_options::merge_environment,
                    execution_options::redirect_stderr_to_stdout
                });
            THEN("error output is returned on stdout") {
                REQUIRE_FALSE(result);
                REQUIRE(output == "File Not Found");
            }
        }
        WHEN("not redirecting stderr to null") {
            string output;
            auto result = each_line(
                "cmd.exe",
                {
                    "/c",
                    "dir",
                    "/B",
                    "does_not_exist"
                },
                [&](string&) {
                    FAIL("should not be called.");
                    return true;
                },
                [&](string& line) {
                    if (!output.empty()) {
                        output += "\n";
                    }
                    output += line;
                    return true;
                });
            THEN("error output is returned") {
                REQUIRE_FALSE(result);
                REQUIRE(output == "File Not Found");
            }
        }
        WHEN("the 'throw on non-zero exit' option is used") {
            THEN("a child exit exception is thrown") {
                REQUIRE_THROWS_AS(each_line("cmd.exe", { "/c", "dir", "/B", "does_not_exist" }, nullptr, nullptr, 0, {execution_options::trim_output, execution_options::merge_environment, execution_options::throw_on_nonzero_exit}), child_exit_exception);
            }
        }
    }
    GIVEN("a long-running command") {
        WHEN("given a timeout") {
            THEN("a timeout exception should be thrown") {
                string ruby = which("ruby.exe");
                if (ruby.empty()) {
                    WARN("skipping command timeout test because no ruby was found on the PATH.");
                    return;
                }
                try {
                    each_line("cmd.exe", { "/c", "ruby.exe", "-e", "sleep 60" }, nullptr, nullptr, 1);
                    FAIL("did not throw timeout exception");
                } catch (timeout_exception const& ex) {
                    // Verify the process was killed
                    REQUIRE(OpenProcess(0, FALSE, ex.pid()) == nullptr);
                } catch (exception const&) {
                    FAIL("unexpected exception thrown");
                }
            }
        }
    }
    GIVEN("stderr is redirected to null") {
        WHEN("using a debug log level") {
            log_capture capture(level::debug);
            REQUIRE(facter::execution::each_line(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/error_message.bat", nullptr));
            THEN("stderr is logged") {
                auto output = capture.result();
                CAPTURE(output);
                REQUIRE(re_search(output, boost::regex("DEBUG !!! - error message!")));
            }
        }
        WHEN("not using a debug log level") {
            log_capture capture(level::warning);
            REQUIRE(facter::execution::each_line(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/windows/execution/error_message.bat", nullptr));
            THEN("stderr is not logged") {
                auto output = capture.result();
                CAPTURE(output);
                REQUIRE_FALSE(re_search(output, boost::regex("DEBUG !!! - error message!")));
            }
        }
    }
}
