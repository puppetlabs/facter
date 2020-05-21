# This test verifies that the external-dir specified in the configuration file can be overridden by using
# --external-dir on the command line
test_name "C100016: config external-dir overridden by command line --external-dir" do
  tag 'risk:medium'

  require 'json'
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "Agent #{agent}: create 2 custom fact directories with facts and a config file pointing at 1 directory" do
      external_config_dir = agent.tmpdir('external_dir')
      external_cli_dir = agent.tmpdir('cli_external_dir')
      external_config_fact = File.join(external_config_dir, 'external.txt')
      external_cli_fact = File.join(external_cli_dir, 'external.txt')
      create_remote_file(agent, external_config_fact, "config_fact=config_value")
      create_remote_file(agent, external_cli_fact, "cli_fact=cli_value")
      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    external-dir : "#{external_config_dir}",
}
EOM
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(external_config_dir)
        agent.rm_rf(external_cli_dir)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: resolve a fact from the command line external-dir and not the config file" do
        on(agent, facter("--config \"#{config_file}\" --external-dir \"#{external_cli_dir}\" --json")) do |facter_output|
          results = JSON.parse(facter_output.stdout)
          assert_equal("cli_value", results['cli_fact'], "Incorrect custom fact value for cli_fact")
          assert_nil(results['config_fact'], "Config fact should not resolve and be nil")
        end
      end
    end
  end
end
