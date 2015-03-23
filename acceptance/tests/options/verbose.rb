test_name "--verbose command-line option prints verbose information to stderr"

agents.each do |agent|
  step "Agent #{agent}: retrieve verbose info from stderr using --verbose option"
  on(agent, "cfacter --verbose") do
    assert_match(/INFO  puppetlabs.facter - executed with command line: --verbose/, stderr, "Expected stderr to contain verbose (INFO) statements")
  end
end
