# This test verifies that setting no-custom-facts in the config file disables
# finding facts under the environment variable FACTERLIB
test_name "C99997: config option no-custom-facts : true does not load facts from FACTERLIB" do
  tag 'risk:high'

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
    step "Agent #{agent}: create a custom fact directory and fact and a config file" do
      facterlib_dir = agent.tmpdir('facterlib')
      custom_fact = File.join(facterlib_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)

      config_dir = agent.tmpdir("config_dir")
      config_file = File.join(config_dir, "facter.conf")
      config_content = <<EOM
global : {
    no-custom-facts : true,
}
EOM
      create_remote_file(agent, config_file, config_content)

      teardown do
        agent.rm_rf(facterlib_dir)
        agent.rm_rf(config_dir)
      end

      step "Agent #{agent}: no-custom-facts should ignore the FACTERLIB environment variable" do
        facter_command = "--config \"#{config_file}\" custom_fact #{@options[:trace]}"
        on(agent, facter(facter_command, :environment => {'FACTERLIB' => facterlib_dir})) do |facter_output|
          assert_equal("", facter_output.stdout.chomp, "Custom fact in FACTERLIB should not have resolved")
        end
      end
    end
  end
end
