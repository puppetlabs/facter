# This test verifies that facter can load facts from a single custom-dir specified
# in the configuration file
test_name "C98143: config custom-dir allows single custom fact directory" do
  tag 'risk:low'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content = <<EOM
Facter.add('config_fact') do
  setcode do
    "config_value"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create custom fact directory and a custom fact and config file" do
      custom_dir = agent.tmpdir('custom_dir')
      custom_fact = File.join(custom_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)
      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    custom-dir : "#{custom_dir}",
}
EOM
      config_content = escape_paths(agent, config_content)
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(custom_dir)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: resolve a fact from the configured custom-dir path" do
        on(agent, facter("--config \"#{config_file}\" config_fact")) do |facter_output|
          assert_equal("config_value", facter_output.stdout.chomp, "Incorrect custom fact value")
        end
      end
    end
  end
end
