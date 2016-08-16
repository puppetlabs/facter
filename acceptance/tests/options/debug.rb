# This test is intended to ensure that the --debug command-line option works
# properly. This option prints debugging information to stderr.
test_name "--debug command-line option prints debugging information to stderr" do

  agents.each do |agent|
    step "Agent #{agent}: retrieve debug info from stderr using --debug option" do
      on(agent, facter('--debug')) do
        assert_match(/DEBUG/, stderr, "Expected DEBUG information in stderr")
      end
    end
  end
end
