# This tests checks that we can call facter with a --external-dir and get an external fact
# from that directory
test_name "C99974: external fact commandline options --external-dir resolves an external fact" do
  tag 'risk:low'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  agents.each do |agent|
    step "Agent #{agent}: create an external fact directory with an external fact" do
      external_dir = agent.tmpdir('external_dir')
      ext = get_external_fact_script_extension(agent['platform'])
      external_fact = File.join(external_dir, "external_fact#{ext}")
      create_remote_file(agent, external_fact, external_fact_content(agent['platform'], 'single_fact', 'external_value'))
      on(agent, "chmod +x '#{external_fact}'")

      teardown do
        on(agent, "rm -rf '#{external_dir}'")
      end

      step "Agent #{agent}: resolve a fact from each specified --external_dir option" do
        on(agent, facter("--external-dir #{external_dir} single_fact")) do |facter_output|
          assert_equal("external_value", facter_output.stdout.chomp, "Incorrect external fact value")
        end
      end
    end
  end
end
