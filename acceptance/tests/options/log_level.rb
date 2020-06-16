# This test is intended to ensure that the --log-level command-line option works
# properly. This option can be used with an argument to specify the level of logging
# which will present in Facter's output.
test_name "C99985: --log-level command-line option can be used to specify logging level" do

  agents.each do |agent|
    step "Agent #{agent}: retrieve debug info from stderr using `--log-level debug` option" do
      on(agent, facter('--log-level debug')) do
        assert_match(/DEBUG/, stderr, "Expected DEBUG information in stderr")
      end
    end
  end
end
