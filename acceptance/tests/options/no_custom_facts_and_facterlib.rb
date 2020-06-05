# This test verifies that --no-custom-facts keeps facter from loading facts from the environment
# variable FACTERLIB
test_name "C100000: custom fact commandline options --no-custom-facts does not load from FACTERLIB" do
  tag 'risk:low'

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
    step "Agent #{agent}: create a custom fact directory and fact" do
      facterlib_dir = agent.tmpdir('facterlib')
      custom_fact = File.join(facterlib_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)

      teardown do
        agent.rm_rf(facterlib_dir)
      end

      step "Agent #{agent}: --no-custom-facts should ignore the FACTERLIB environment variable" do
        on(agent, facter('--no-custom-facts custom_fact', :environment => { 'FACTERLIB' => facterlib_dir })) do |facter_output|
          assert_equal("", facter_output.stdout.chomp, "Custom fact in FACTERLIB should not have resolved")
        end
      end
    end
  end
end
