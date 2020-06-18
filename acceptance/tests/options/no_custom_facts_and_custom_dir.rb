# This test verifies that calling facter with both --no-custom-facts and --custom-dir results
# in an options conflict error
test_name "C100001: custom fact commandline options --no-custom-facts together with --custom-dir should produce an error" do
  tag 'risk:low'

  agents.each do |agent|
    custom_dir = agent.tmpdir('custom_dir')

    teardown do
      on(agent, "rm -rf '#{custom_dir}'")
    end

    step "Agent #{agent}: --no-custom-facts and --custom-dir options should result in a error" do
      on(agent, facter("--no-custom-facts --custom-dir '#{custom_dir}'"), :acceptable_exit_codes => 1) do |facter_output|
        assert_match(/options conflict/, facter_output.stderr.chomp, "Output does not contain error string")
      end
    end
  end
end
