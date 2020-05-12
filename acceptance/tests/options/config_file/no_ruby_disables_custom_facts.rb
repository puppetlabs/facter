# This test is intended to demonstrate that the global.no-ruby config file field
# disables custom fact lookup.
test_name "C100045: config no-ruby to true should disable custom facts" do
  tag 'risk:high'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  config = <<EOM
global : {
    no-ruby : true
}
EOM

  custom_fact_content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "testvalue"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create config file" do
      config_dir = get_default_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      config_file = File.join(config_dir, "facter.conf")
      agent.mkdir_p(config_dir)
      create_remote_file(agent, config_file, config)

      teardown do
        agent.rm_rf(config_dir)
      end

      step "no-ruby option should disable custom facts" do
        step "Agent #{agent}: create custom fact directory and custom fact" do
          custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
          agent.mkdir_p(custom_dir)
          custom_fact = File.join(custom_dir, 'custom_fact.rb')
          create_remote_file(agent, custom_fact, custom_fact_content)

          teardown do
            agent.rm_rf(custom_dir)
          end

          on(agent, facter("custom_fact", :environment => { 'FACTERLIB' => custom_dir })) do |facter_output|
            assert_equal("", facter_output.stdout.chomp, "Expected custom fact to be disabled when no-ruby is true")
          end
        end
      end
    end
  end
end
