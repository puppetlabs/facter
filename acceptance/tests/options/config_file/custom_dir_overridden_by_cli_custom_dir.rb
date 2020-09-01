# This test verifies that the custom-dir specified in the configuration file can be overridden by using
# --custom-dir on the command line
test_name "C100015: config custom-dir overridden by command line --custom-dir" do
  tag 'risk:medium'

  require 'json'
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  config_fact_content = <<EOM
Facter.add('config_fact') do
  setcode do
    "config_value"
  end
end
EOM

  cli_fact_content = <<EOM
Facter.add('cli_fact') do
  setcode do
    "cli_value"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create 2 custom fact directories with facts and a config file pointing at 1 directory" do
      custom_config_dir = agent.tmpdir('custom_dir')
      custom_cli_dir = agent.tmpdir('cli_custom_dir')
      custom_config_fact = File.join(custom_config_dir, 'custom_fact.rb')
      custom_cli_fact = File.join(custom_cli_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_config_fact, config_fact_content)
      create_remote_file(agent, custom_cli_fact, cli_fact_content)
      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    custom-dir : "#{custom_config_dir}",
}
EOM

      config_content = escape_paths(agent, config_content)
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(custom_config_dir)
        agent.rm_rf(custom_cli_dir)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: resolve a fact from the command line custom-dir and not the config file" do
        on(agent, facter("--config \"#{config_file}\" --custom-dir \"#{custom_cli_dir}\" --json")) do |facter_output|
          results = JSON.parse(facter_output.stdout)
          assert_equal("cli_value", results['cli_fact'], "Incorrect custom fact value for cli_fact")
          assert_nil(results['config_fact'], "Config fact should not resolve and be nil")
        end
      end
    end
  end
end
