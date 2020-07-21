# This test verifies that --no-external-facts does not load external facts

test_name "C99961: external fact command line option --no-external-facts does not load external facts" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "Agent #{agent}: create external fact directory and external fact" do
      external_dir = agent.tmpdir('external_dir')
      ext = get_external_fact_script_extension(agent['platform'])
      external_fact = File.join(external_dir, "external_fact#{ext}")
      create_remote_file(agent, external_fact, external_fact_content(agent['platform'], 'external_fact', 'external_value'))
      agent.chmod('+x', external_fact)

      teardown do
        agent.rm_rf(external_dir)
      end

      step "Agent #{agent}: --no-external-facts option should not load external facts" do
        on(agent, facter("--no-external-facts external_fact")) do |facter_output|
          assert_equal("", facter_output.stdout.chomp, "External fact should not have resolved")
        end
      end
    end
  end
end
