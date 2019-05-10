#include <catch.hpp>
#include <facter/facts/collection.hpp>
#include <leatherman/execution/execution.hpp>
#include <leatherman/util/environment.hpp>
#include <boost/filesystem.hpp>
#include "../fixtures.hpp"

using namespace std;
using namespace facter::facts;
using namespace leatherman::execution;
using namespace leatherman::util;
using namespace boost::filesystem;
using namespace facter::testing;

SCENARIO("using libfacter from Java") {
    collection_fixture facts;
    facts.add_default_facts(true);

    path jar_path = path(BINARY_DIRECTORY) / "lib" / "facter.jar";

    CAPTURE(JAVA_EXECUTABLE);
    CAPTURE(BINARY_DIRECTORY);
    CAPTURE(jar_path);

    GIVEN("the os fact") {
        try {
            auto exec = execute(
                JAVA_EXECUTABLE,
                {
                    "-jar",
                    jar_path.string(),
                    "os"
                },
                {
                    { "FACTERDIR", BINARY_DIRECTORY }
                },
                0,
                {
                    execution_options::trim_output,
                    execution_options::merge_environment,
                    execution_options::throw_on_failure
                });
            CAPTURE(exec.output);
            CAPTURE(exec.error);
            THEN("the value should match") {
                REQUIRE(exec.success);
                ostringstream ss;
                auto value = facts["os"];
                REQUIRE(value);
                value->write(ss);
                REQUIRE(exec.output == ss.str());
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
