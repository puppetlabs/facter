# This test verifies that calling facter with both --no-external-facts and --external-dir results
# in an options conflict error
test_name "C100002: external fact commandline options --no-external-facts together with --external-dir should produce an error" do
  tag 'risk:high'

  agents.each do |agent|
    external_dir = agent.tmpdir('external_dir')

    teardown do
      agent.rm_rf(external_dir)
    end

    step "Agent #{agent}: --no-external-facts and --external-dir options should result in a error" do
      facter_command = "--no-external-facts --external-dir '#{external_dir}' #{@options[:trace]}"
      on(agent, facter(facter_command), :acceptable_exit_codes => 1) do |facter_output|
        assert_match(/options conflict/, facter_output.stderr.chomp, "Output does not contain error string")
      end
    end
  end
end
