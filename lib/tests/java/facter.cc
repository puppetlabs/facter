#include <catch.hpp>
#include <facter/facts/collection.hpp>
#include <facter/execution/execution.hpp>
#include <facter/util/environment.hpp>
#include <boost/filesystem.hpp>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace facter::execution;
using namespace facter::util;
using namespace boost::filesystem;

SCENARIO("using libfacter from Java") {
    collection facts;
    facts.add_default_facts();

    path jar_path = path(BINARY_DIRECTORY) / "lib" / "facter.jar";

    string system_path;
    environment::get("PATH", system_path);

    CAPTURE(JAVA_EXECUTABLE);
    CAPTURE(LIBFACTER_OUTPUT_DIRECTORY);
    CAPTURE(jar_path);

    GIVEN("the os fact") {
        try {
            bool success;
            string output, error;
            tie(success, output, error) = execute(
                JAVA_EXECUTABLE,
                {
                    "-jar",
                    jar_path.string(),
                    "os"
                },
                {
                    { "FACTERDIR", LIBFACTER_OUTPUT_DIRECTORY },
                    { "PATH", string(LIBFACTER_OUTPUT_DIRECTORY) + environment::get_path_separator() + system_path }
                },
                0,
                {
                    execution_options::trim_output,
                    execution_options::merge_environment,
                    execution_options::throw_on_failure
                });
            THEN("the value should match") {
                REQUIRE(success);
                REQUIRE(error.empty());
                ostringstream ss;
                auto value = facts["os"];
                REQUIRE(value);
                value->write(ss);
                REQUIRE(output == ss.str());
            }
        } catch (child_exit_exception const& ex) {
            CAPTURE(ex.output());
            CAPTURE(ex.error());
            CAPTURE(ex.status_code());
            FAIL("exception from child process.");
        } catch (child_signal_exception const& ex) {
            CAPTURE(ex.output());
            CAPTURE(ex.error());
            CAPTURE(ex.signal());
            FAIL("signal from child process.");
        }
    }
}
