# This test is intended to ensure with --debug and --color, facter sends escape sequences to colorize the output
test_name "C86545: --debug and --color command-line options should print DEBUG messages with color escape sequences" do
  tag 'risk:high'

  confine :except, :platform => 'windows' # On windows we don't get an escape sequence to detect to color change

  agents.each do |agent|
    step "Agent #{agent}: retrieve debug info from stderr using --debug and --color option" do
      # set the TERM type to be a color xterm to help ensure we emit the escape sequence to change the color
      on(agent, facter("--debug --color #{@options[:trace]}"),
         :environment => { 'TERM' => 'xterm-256color' }) do |facter_output|
        assert_match(/DEBUG/, facter_output.stderr, "Expected DEBUG information in stderr")
        assert_match(
          /\e\[(\d{2,3})?;?(\d{1})?;?(\d{2,3})?m/,
          facter_output.stderr,
          "Expected to see an escape sequence in the output"
        )
      end
    end
  end
end
