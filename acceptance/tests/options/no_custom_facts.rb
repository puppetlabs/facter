# This test verifies that --no-custom-facts does not load custom facts
test_name "C64171: custom fact command line option --no-custom-facts does not load custom facts" do
  tag 'risk:med'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "testvalue"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create custom fact directory and custom fact" do
      custom_dir = get_user_fact_dir(agent['platform'], on(agent, facter('kernelmajversion')).stdout.chomp.to_f)
      on(agent, "mkdir -p '#{custom_dir}'")
      custom_fact = File.join(custom_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)

      teardown do
        on(agent, "rm -f '#{custom_fact}'")
      end

      step "Agent #{agent}: --no-custom-facts option should not load custom facts" do
        on(agent, facter("--no-custom-facts custom_fact")) do
          assert_equal("", stdout.chomp, "Expected custom fact to be empty, but it resolved as #{stdout.chomp}")
        end
      end
    end
  end
end
