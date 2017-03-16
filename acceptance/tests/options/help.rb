# This test is intended to ensure that the --help command-line option works
# properly. This option prints usage information and available command-line
# options.
test_name "C99984: --help command-line option prints usage information to stdout" do

  agents.each do |agent|
    step "Agent #{agent}: retrieve usage info from stdout using --help option" do
      on(agent, facter('--help')) do
        assert_match(/facter \[options\] \[query\] \[query\] \[...\]/, stdout, "Expected stdout to contain usage information")
      end
    end
  end
end
