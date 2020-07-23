# This test verifies that no-external-facts : true set in the configuration file
# does not load external facts
test_name "C99962: config no-external-facts : true does not load external facts" do
  tag 'risk:medium'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "Agent #{agent}: create external fact directory and external fact and a config file" do
      external_dir = agent.tmpdir('external_dir')
      ext = get_external_fact_script_extension(agent['platform'])
      external_fact = File.join(external_dir, "external_fact#{ext}")
      create_remote_file(agent, external_fact, external_fact_content(agent['platform'], 'external_fact', 'external_value'))
      agent.chmod('+x', external_fact)

      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    no-external-facts : true,
}
EOM
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(external_dir)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: --no-external-facts option should not load external facts" do
        on(agent, facter("--no-external-facts external_fact")) do |facter_output|
          assert_equal("", facter_output.stdout.chomp, "External fact should not have resolved")
        end
      end
    end
  end
end
