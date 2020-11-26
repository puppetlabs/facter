# This test is intended to ensure that the --version command-line option works
# properly. This option outputs the current Facter version.
test_name "C99983: --version command-line option returns the version string" do

  agents.each do |agent|
    step "Agent #{agent}: retrieve version info using the --version option" do
      on(agent, facter("--version #{@options[:trace]}")) do
        assert_match(/\d+\.\d+\.\d+/, stdout, "Output #{stdout} is not a recognized version string")
      end
    end
  end
end
