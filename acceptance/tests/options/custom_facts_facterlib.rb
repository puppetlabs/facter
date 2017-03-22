# This test verifies that we can load a custom fact using the environment variable FACTERLIB
test_name "C14779: custom facts are loaded from the environment variable FACTERLIB path" do
  tag 'risk:medium'

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "facterlib"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: create custom directory and fact" do
      custom_dir = agent.tmpdir('facter_lib_dir')
      custom_fact = File.join(custom_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)

      teardown do
        on(agent, "rm -rf '#{custom_dir}'")
      end

      step "Agent #{agent}: facter should resolve a fact from the directory specified by the environment variable FACTERLIB" do
        on(agent, facter('custom_fact', :environment => { 'FACTERLIB' => custom_dir })) do |facter_output|
          assert_equal("facterlib", facter_output.stdout.chomp, "Incorrect custom fact value for fact in FACTERLIB")
        end
      end
    end
  end
end
