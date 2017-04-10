# This test is intended to ensure with --debug and --no-color, facter does not send any escape sequences
# to colorize the output
test_name "C99975: --debug and --no-color command-line options should print DEBUG messages without color escape sequences" do
  tag 'risk:low'

  confine :except, :platform => 'windows' # On windows we don't get an escape sequence so we can't detect a color change

  agents.each do |agent|
    step "Agent #{agent}: retrieve debug info from stderr using --debug anod --no-color options" do
      on(agent, facter('--debug --no-color')) do |facter_output|
        assert_match(/DEBUG/, facter_output.stderr, "Expected DEBUG information in stderr")
        refute_match(/\e\[0;/, facter_output.stderr, "Expected to output to not contain an escape sequence")
      end
    end
  end
end