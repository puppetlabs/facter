test_name "--verbose command-line option prints verbose information to stderr"

#
# This test is intended to ensure that the --verbose command-line option
# works properly. This option provides verbose (INFO) output to stderr.
#

agents.each do |agent|
  step "Agent #{agent}: retrieve verbose info from stderr using --verbose option"
  on(agent, facter('--verbose')) do
    assert_match(/INFO  puppetlabs.facter - executed with command line: --verbose/, stderr, "Expected stderr to contain verbose (INFO) statements")
  end
end
