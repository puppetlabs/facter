# facter should be able to load facts from multiple external-dir's specified
# in the configuration file
test_name "C99995: config file supports external-dir for multiple fact directories" do
  tag 'risk:medium'

  require 'json'
  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "Agent #{agent}: create external fact directories and a external fact in each and a config file" do
      external_dir_1 = agent.tmpdir('external_dir_1')
      external_dir_2 = agent.tmpdir('external_dir_2')
      ext = get_external_fact_script_extension(agent['platform'])
      external_fact_1 = File.join(external_dir_1, "external_fact#{ext}")
      external_fact_2 = File.join(external_dir_2, "external_fact#{ext}")
      create_remote_file(agent, external_fact_1, external_fact_content(agent['platform'], 'external_fact_1', 'external_value_1'))
      create_remote_file(agent, external_fact_2, external_fact_content(agent['platform'], 'external_fact_2', 'external_value_2'))
      agent.chmod('+x', external_fact_1)
      agent.chmod('+x', external_fact_2)


      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    external-dir : [ "#{external_dir_1}", "#{external_dir_2}" ],
}
EOM
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(external_dir_1)
        agent.rm_rf(external_dir_2)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: resolve a fact from each configured external-dir path" do
        on(agent, facter("--config '#{config_file}' --json")) do |facter_output|
          results = JSON.parse(facter_output.stdout)
          assert_equal("external_value_1", results['external_fact_1'], "Incorrect external fact value for external_fact_1")
          assert_equal("external_value_2", results['external_fact_2'], "Incorrect external fact value for external_fact_2")
        end
      end
    end
  end
end
