#include <catch.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/string.hpp>
#include <boost/algorithm/string.hpp>
#include "../../fixtures.hpp"
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>

using namespace std;
using namespace facter::util;
using namespace facter::execution;
using namespace facter::testing;

SCENARIO("searching for programs with execution::which") {
    GIVEN("an absolute path to an executable file") {
        THEN("the same path should be returned") {
            REQUIRE(
                which(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts") ==
                LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts"
            );
        }
    }
    GIVEN("an absolute path to a non-executable file") {
        THEN("an empty string should be returned") {
            REQUIRE(
                which(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/not_executable") ==
                ""
            );
        }
    }
    GIVEN("an absolute path to a non-existant file") {
        THEN("an empty string should be returned") {
            REQUIRE(
                which(LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/does_not_exist") ==
                ""
            );
        }
    }
    GIVEN("an executable file on the PATH") {
        THEN("the full path should be returned") {
            REQUIRE(
                which("facts", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }) ==
                LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts"
            );
        }
    }
    GIVEN("a path relative to a directory on PATH") {
        THEN("the full path should be returned") {
            REQUIRE(
                which("posix/execution/facts", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external" }) ==
                LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts"
            );
        }
    }
    GIVEN("a file that does not exist on PATH") {
        THEN("an empty string should be returned") {
            REQUIRE(
                which("not_on_the_path") ==
                ""
            );
        }
    }
    GIVEN("a file that is not executable") {
        THEN("an empty string should be returned") {
            REQUIRE(
                which("not_executable", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }) ==
                ""
            );
        }
    }
}

SCENARIO("expanding command paths with execution::expand_command") {
    GIVEN("an executable on the PATH") {
        THEN("the executable is expanded to an absolute path") {
            REQUIRE(
                expand_command("facts 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }) ==
                LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts 1 2 3"
            );
        }
    }
    GIVEN("a single-quoted command") {
        THEN("the expanded path should be single-quoted") {
            REQUIRE(
                expand_command("'facts' 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }) ==
                "'" LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts' 1 2 3"
            );
        }
    }
    GIVEN("a double-quoted command") {
        THEN("the expanded path should be double-quoted") {
            REQUIRE(
                expand_command("\"facts\" 1 2 3", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }) ==
                "\"" LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution/facts\" 1 2 3"
            );
        }
    }
    GIVEN("a command not on PATH") {
        THEN("the command is returned as given") {
            REQUIRE(
                expand_command("not_on_the_path") ==
                "not_on_the_path"
            );
        }
    }
    GIVEN("a non-executable command on PATH") {
        THEN("the command is returned as given") {
            REQUIRE(
                expand_command("not_executable", { LIBFACTER_TESTS_DIRECTORY "/fixtures/facts/external/posix/execution" }) ==
                "not_executable"
            );
        }
    }
}

SCENARIO("executing commands with execution::execute") {
    auto get_variables = [](std::string const& input) {
        map<string, string> variables;
        facter::util::each_line(input, [&](string& line) {
            vector<string> parts;
            boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
            if (parts.size() != 2) {
                return true;
            }
            variables.emplace(make_pair(move(parts[0]), move(parts[1])));
            return true;
        });
        return variables;
    };
    GIVEN("a command that succeeds") {
        THEN("the output should be returned") {
            auto result = execute("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file3.txt" });
            REQUIRE(result.first);
            REQUIRE(result.second == "file3");
        }
        WHEN("requested to merge the environment") {
            setenv("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE", 1);
            auto result = execute("env", {}, { {"TEST_VARIABLE1", "TEST_VALUE1" }, {"TEST_VARIABLE2", "TEST_VALUE2" } });
            unsetenv("TEST_INHERITED_VARIABLE");
            REQUIRE(result.first);
            auto variables = get_variables(result.second);
            THEN("the child environment should contain the given variables") {
                REQUIRE(variables.size() > 4);
                REQUIRE(variables.count("TEST_VARIABLE1") == 1);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
                REQUIRE(variables.count("TEST_VARIABLE1") == 1);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
            }
            THEN("the child environment should have LC_ALL and LANG set to C") {
                REQUIRE(variables.count("LC_ALL") == 1);
                REQUIRE(variables["LC_ALL"] == "C");
                REQUIRE(variables.count("LANG") == 1);
                REQUIRE(variables["LANG"] == "C");
            }
        }
        WHEN("requested to override the environment") {
            option_set<execution_options> options = { execution_options::defaults };
            options.clear(execution_options::merge_environment);
            setenv("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE", 1);
            auto result = execute("env", {}, { {"TEST_VARIABLE1", "TEST_VALUE1" }, {"TEST_VARIABLE2", "TEST_VALUE2" }}, options);
            unsetenv("TEST_INHERITED_VARIABLE");
            REQUIRE(result.first);
            auto variables = get_variables(result.second);
            THEN("the child environment should only contain the given variables") {
                REQUIRE(variables.size() == 4);
                REQUIRE(variables.count("TEST_VARIABLE1") == 1);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
                REQUIRE(variables.count("TEST_VARIABLE1") == 1);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
            }
            THEN("the child environment should have LC_ALL and LANG set to C") {
                REQUIRE(variables.count("LC_ALL") == 1);
                REQUIRE(variables["LC_ALL"] == "C");
                REQUIRE(variables.count("LANG") == 1);
                REQUIRE(variables["LANG"] == "C");
            }
        }
        WHEN("requested to override LC_ALL or LANG") {
            auto result = execute("env", {}, { {"LANG", "FOO" }, { "LC_ALL", "BAR" } });
            REQUIRE(result.first);
            auto variables = get_variables(result.second);
            THEN("the values should be passed to the child process") {
                REQUIRE(variables.count("LC_ALL") == 1);
                REQUIRE(variables["LC_ALL"] == "BAR");
                REQUIRE(variables.count("LANG") == 1);
                REQUIRE(variables["LANG"] == "FOO");
            }
        }
    }
    GIVEN("a command that fails") {
        WHEN("default options are used") {
            auto result = execute("ls", { "does_not_exist" });
            THEN("no output is returned") {
                REQUIRE_FALSE(result.first);
                REQUIRE(result.second == "");
            }
        }
        WHEN("the redirect STDERR option is used") {
            auto result = execute("ls", { "does_not_exist" }, option_set<execution_options>({ execution_options::defaults, execution_options::redirect_stderr }));
            THEN("error output is returned") {
                REQUIRE_FALSE(result.first);
                REQUIRE(boost::ends_with(result.second, "No such file or directory"));
            }
        }
        WHEN("the 'throw on non-zero exit' option is used") {
            THEN("a child exit exception is thrown") {
                REQUIRE_THROWS_AS(execute("ls", {"does_not_exist"}, option_set<execution_options>({execution_options::defaults, execution_options::throw_on_nonzero_exit})), child_exit_exception);
            }
        }
        WHEN("the 'throw on signal' option is used") {
            THEN("a child signal exception is thrown") {
                REQUIRE_THROWS_AS(execute("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/selfkill.sh" }, option_set<execution_options>({ execution_options::defaults, execution_options::throw_on_signal })), child_signal_exception);
            }
        }
    }
    GIVEN("a command that outputs leading/trailing whitespace") {
        THEN("whitespace should be trimmed by default") {
            auto result = execute("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt" });
            REQUIRE(result.first);
            REQUIRE(result.second == "this is a test of trimming");
        }
        WHEN("the 'trim whitespace' option is not used") {
            option_set<execution_options> options = { execution_options::defaults };
            options.clear(execution_options::trim_output);
            auto result = execute("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file1.txt" }, options);
            THEN("whitespace should not be trimmed") {
                REQUIRE(result.second == "   this is a test of trimming   ");
            }
        }
    }
    GIVEN("a long-running command") {
        WHEN("given a timeout") {
            THEN("a timeout exception should be thrown") {
                option_set<execution_options> options = { execution_options::defaults };
                try {
                    execute("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/sleep.sh" }, options, 1);
                    FAIL("did not throw timeout exception");
                } catch (timeout_exception const& ex) {
                    // Verify the process group was killed by waiting for it
                    int status = 0;
                    REQUIRE(waitpid(-ex.pid(), &status, WNOHANG) == -1);
                    REQUIRE(errno == ECHILD);
                } catch (exception const&) {
                    FAIL("unexpected exception thrown");
                }
            }
        }
    }
}

SCENARIO("executing commands with execution::each_line") {
    GIVEN("a command that succeeds") {
        THEN("each line of output should be returned") {
            vector<string> lines;
            bool success = each_line("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file4.txt" }, [&](string& line) {
                lines.push_back(line);
                return true;
            });
            REQUIRE(success);
            REQUIRE(lines.size() == 4);
            REQUIRE(lines[0] == "line1");
            REQUIRE(lines[1] == "line2");
            REQUIRE(lines[2] == "line3");
            REQUIRE(lines[3] == "line4");
        }
        WHEN("output stops when false is returned from callback") {
            vector<string> lines;
            bool success = each_line("cat", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/ls/file4.txt" }, [&](string& line) {
                lines.push_back(line);
                return false;
            });
            REQUIRE(success);
            REQUIRE(lines.size() == 1);
            REQUIRE(lines[0] == "line1");
        }
        WHEN("requested to merge the environment") {
            setenv("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE", 1);
            map<string, string> variables;
            bool success = each_line("env", {}, { {"TEST_VARIABLE1", "TEST_VALUE1" }, {"TEST_VARIABLE2", "TEST_VALUE2" } }, [&](string& line) {
                vector<string> parts;
                boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
                if (parts.size() != 2) {
                    return true;
                }
                variables.emplace(make_pair(move(parts[0]), move(parts[1])));
                return true;
            });
            unsetenv("TEST_INHERITED_VARIABLE");
            REQUIRE(success);
            THEN("the child environment should contain the given variables") {
                REQUIRE(variables.size() > 4);
                REQUIRE(variables.count("TEST_VARIABLE1") == 1);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
                REQUIRE(variables.count("TEST_VARIABLE1") == 1);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
            }
            THEN("the child environment should have LC_ALL and LANG set to C") {
                REQUIRE(variables.count("LC_ALL") == 1);
                REQUIRE(variables["LC_ALL"] == "C");
                REQUIRE(variables.count("LANG") == 1);
                REQUIRE(variables["LANG"] == "C");
            }
        }
        WHEN("requested to override the environment") {
            option_set<execution_options> options = { execution_options::defaults };
            options.clear(execution_options::merge_environment);
            setenv("TEST_INHERITED_VARIABLE", "TEST_INHERITED_VALUE", 1);
            map<string, string> variables;
            bool success = each_line("env", {}, { {"TEST_VARIABLE1", "TEST_VALUE1" }, {"TEST_VARIABLE2", "TEST_VALUE2" } }, [&](string& line) {
                vector<string> parts;
                boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
                if (parts.size() != 2) {
                    return true;
                }
                variables.emplace(make_pair(move(parts[0]), move(parts[1])));
                return true;
            }, options);
            unsetenv("TEST_INHERITED_VARIABLE");
            REQUIRE(success);
            THEN("the child environment should only contain the given variables") {
                REQUIRE(variables.size() == 4);
                REQUIRE(variables.count("TEST_VARIABLE1") == 1);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
                REQUIRE(variables.count("TEST_VARIABLE1") == 1);
                REQUIRE(variables["TEST_VARIABLE1"] == "TEST_VALUE1");
            }
            THEN("the child environment should have LC_ALL and LANG set to C") {
                REQUIRE(variables.count("LC_ALL") == 1);
                REQUIRE(variables["LC_ALL"] == "C");
                REQUIRE(variables.count("LANG") == 1);
                REQUIRE(variables["LANG"] == "C");
            }
        }
        WHEN("requested to override LC_ALL or LANG") {
            map<string, string> variables;
            bool success = each_line("env", {}, { {"LANG", "FOO" }, { "LC_ALL", "BAR" } }, [&](string& line) {
                vector<string> parts;
                boost::split(parts, line, boost::is_any_of("="), boost::token_compress_off);
                if (parts.size() != 2) {
                    return true;
                }
                variables.emplace(make_pair(move(parts[0]), move(parts[1])));
                return true;
            });
            REQUIRE(success);
            THEN("the values should be passed to the child process") {
                REQUIRE(variables.count("LC_ALL") == 1);
                REQUIRE(variables["LC_ALL"] == "BAR");
                REQUIRE(variables.count("LANG") == 1);
                REQUIRE(variables["LANG"] == "FOO");
            }
        }
    }
    GIVEN("a command that fails") {
        WHEN("default options are used") {
            THEN("no output is returned") {
                auto success = each_line("ls", { "does_not_exist" }, [](string& line) {
                    FAIL("should not be called");
                    return true;
                });
                REQUIRE_FALSE(success);
            }
        }
        WHEN("the redirect STDERR option is used") {
            string output;
            auto result = each_line("ls", { "does_not_exist" }, [&](string& line) {
                if (!output.empty()) {
                    output += "\n";
                }
                output += line;
                return true;
            }, option_set<execution_options>({ execution_options::defaults, execution_options::redirect_stderr }));
            THEN("error output is returned") {
                REQUIRE_FALSE(result);
                REQUIRE(boost::ends_with(output, "No such file or directory"));
            }
        }
        WHEN("the 'throw on non-zero exit' option is used") {
            THEN("a child exit exception is thrown") {
                REQUIRE_THROWS_AS(each_line("ls", {"does_not_exist"}, [](string& line) { return true; }, option_set<execution_options>({execution_options::defaults, execution_options::throw_on_nonzero_exit})), child_exit_exception);
            }
        }
        WHEN("the 'throw on signal' option is used") {
            THEN("a child signal exception is thrown") {
                REQUIRE_THROWS_AS(each_line("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/selfkill.sh" }, [](string& line) { return true; }, option_set<execution_options>({ execution_options::defaults, execution_options::throw_on_signal })), child_signal_exception);
            }
        }
    }
    GIVEN("a long-running command") {
        WHEN("given a timeout") {
            THEN("a timeout exception should be thrown") {
                try {
                    option_set<execution_options> options = { execution_options::defaults };
                    each_line("sh", { LIBFACTER_TESTS_DIRECTORY "/fixtures/execution/sleep.sh" }, [](string& line) { return true; }, options, 1);
                    FAIL("did not throw timeout exception");
                } catch (timeout_exception const& ex) {
                    // Verify the process group was killed by waiting for it
                    int status = 0;
                    REQUIRE(waitpid(-ex.pid(), &status, WNOHANG) == -1);
                    REQUIRE(errno == ECHILD);
                } catch (exception const&) {
                    FAIL("unexpected exception thrown");
                }
            }
        }
    }
}
