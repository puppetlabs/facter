# This test verifies that setting external-dir and no-external-facts in the config file
# results in an error
test_name "C99993: config option no-external-facts conflicts with external-dir" do
  tag 'risk:low'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "Agent #{agent}: create the exernal-dir and a config file" do
      external_dir = agent.tmpdir('external_dir')

      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    external-dir : "#{external_dir}"
    no-external-facts : true,
}
EOM
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(external_dir)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: config option no-external-facts : true and external-dir should result in an options conflict error" do
        on(agent, facter("--config \"#{config_file}\""), :acceptable_exit_codes => 1) do |facter_output|
          assert_match(/options conflict/, facter_output.stderr, "Output does not contain error string")
        end
      end
    end
  end
end
