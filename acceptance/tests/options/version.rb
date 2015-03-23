test_name "--version command-line option returns the version string"

#
# This test is intended to ensure that the --version command-line option works
# properly. This option outputs the current Facter version.
#

agents.each do |agent|
  step "Agent #{agent}: retrieve version info using the --version option"
  on(agent, "facter --version") do
    assert_match(/\d+\.\d+\.\d+/, stdout, "Output #{stdout} is not a recognized version string")
  end
end
