# This test verifies that --no-external-facts does not load external facts

test_name "C99961: external fact command line option --no-external-facts does not load external facts" do
  tag 'risk:medium'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "Agent #{agent}: create external fact directory and external fact" do

      external_dir = agent.tmpdir('external_dir')
      on(agent, "mkdir -p '#{external_dir}'")
      ext = get_external_fact_script_extension(agent['platform'])
      external_fact     = File.join(external_dir, "external_fact#{ext}")
      create_remote_file(agent, external_fact, external_fact_content(agent['platform'], 'external_fact', 'external_value'))
      on(agent, "chmod +x '#{external_fact}'")

      teardown do
        on(agent, "rm -rf '#{external_dir}'")
      end

      step "Agent #{agent}: --no-external-facts option should not load external facts" do
        on(agent, facter("--no-external-facts external_fact")) do
          assert_equal("", stdout.chomp, "Expected external fact to be empty, but it resolved as #{stdout.chomp}")
        end
      end
    end
  end
end
