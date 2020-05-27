# This test verifies that facter can load facts from a single external-dir specified
# in the configuration file
test_name "C98142: config external-dir allows single external fact directory" do
  tag 'risk:low'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "Agent #{agent}: create an external fact directory with an external fact and a config file" do
      external_dir = agent.tmpdir('external_dir')
      ext = get_external_fact_script_extension(agent['platform'])
      external_fact = File.join(external_dir, "external_fact#{ext}")
      create_remote_file(agent, external_fact, external_fact_content(agent['platform'], 'single_fact', 'external_value'))
      agent.chmod('+x', external_fact)

      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    external-dir : "#{external_dir}",
}
EOM
      config_content = escape_paths(agent, config_content)
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(external_dir)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: resolve a fact in the external-dir in the configuration file" do
        on(agent, facter("--config \"#{config_file}\" single_fact")) do |facter_output|
          assert_equal("external_value", facter_output.stdout.chomp, "Incorrect external fact value")
        end
      end
    end
  end
end
