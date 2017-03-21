# This test checks that we can call facter with a --custom-dir and get a custom fact
# from that directory
test_name "C14905: custom fact command line option --custom-dir loads custom fact" do
  tag 'risk:low'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "single_fact"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create custom fact directory and a custom fact" do
      custom_dir = agent.tmpdir('custom_dir')
      on(agent, "mkdir -p '#{custom_dir}'")
      custom_fact = File.join(custom_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)

      teardown do
        on(agent, "rm -rf '#{custom_dir}'")
      end

      step "Agent #{agent}: --custom-dir option should resolve custom facts from the specific directory" do
        on(agent, facter("--custom-dir '#{custom_dir}' custom_fact")) do
          assert_equal("single_fact", stdout.chomp, "Custom fact output does not match expected output #{stdout.chomp}")
        end
      end
    end
  end
end
