# This test verifies that setting both custom-dir and no-custom-facts results in an error
test_name "C99994: config option no-custom-facts conflicts with custom-dir" do
  tag 'risk:low'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "testvalue"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create a custom fact directory and fact and a config file" do
      custom_dir = agent.tmpdir('custom_dir')
      custom_fact = File.join(custom_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)

      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    custom-dir : "#{custom_dir}"
    no-custom-facts : true,
}
EOM
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(custom_fact)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: config option no-custom-facts : true and custom-dir should result in an options conflict error" do
        on(agent, facter("--config '#{config_file}'"), :acceptable_exit_codes => 1) do |facter_output|
          assert_match(/options conflict/, facter_output.stderr, "Output does not contain error string")
        end
      end
    end
  end
end
