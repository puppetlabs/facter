# This test verifies that calling facter with both --no-external-facts and --external-dir results
# in an options conflict error
test_name "C100002: external fact commandline options --no-external-facts together with --external-dir should produce an error" do
  tag 'risk:low'

  agents.each do |agent|
    external_dir = agent.tmpdir('external_dir')

    teardown do
      agent.rm_rf(external_dir)
    end

    step "Agent #{agent}: --no-external-facts and --external-dir options should result in a error" do
      on(agent, facter("--no-external-facts --external-dir '#{external_dir}'"), :acceptable_exit_codes => 1) do |facter_output|
        assert_match(/options conflict/, facter_output.stderr.chomp, "Output does not contain error string")
      end
    end
  end
end
