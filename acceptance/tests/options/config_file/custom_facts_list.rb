# This test verifies that facter can load facts from multiple custom-dir's specified
# in the configuration file
test_name "C99996: config custom-dir allows multiple custom fact directories" do
  tag 'risk:medium'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content_1 = <<EOM
Facter.add('config_fact_1') do
  setcode do
    "config_value_1"
  end
end
EOM

  content_2 = <<EOM
Facter.add('config_fact_2') do
  setcode do
    "config_value_2"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create custom fact directories and a custom fact in each and a config file" do
      custom_dir_1 = agent.tmpdir('custom_dir_1')
      custom_dir_2 = agent.tmpdir('custom_dir_2')
      custom_fact_1 = File.join(custom_dir_1, 'custom_fact.rb')
      custom_fact_2 = File.join(custom_dir_2, 'custom_fact.rb')
      create_remote_file(agent, custom_fact_1, content_1)
      create_remote_file(agent, custom_fact_2, content_2)

      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    custom-dir : [ "#{custom_dir_1}", "#{custom_dir_2}" ],
}
EOM
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(custom_dir_1)
        agent.rm_rf(custom_dir_2)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: resolve a fact from each configured custom-dir path" do
        on(agent, facter("--config \"#{config_file}\" --json")) do |facter_output|
          results = JSON.parse(facter_output.stdout)
          assert_equal("config_value_1", results['config_fact_1'], "Incorrect custom fact value for config_fact_1")
          assert_equal("config_value_2", results['config_fact_2'], "Incorrect custom fact value for config_fact_2")
        end
      end
    end
  end
end
