test_name "--version command-line option returns the version string"

agents.each do |agent|
  step "Agent #{agent}: retrieve version info using the --version option"
  on(agent, "cfacter --version") do
    assert_match(/\d+\.\d+\.\d+/, stdout, "Output #{stdout} is not a recognized version string")
  end
end
