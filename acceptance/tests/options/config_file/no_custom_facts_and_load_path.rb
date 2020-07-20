# This test verifies that setting no-custom-facts in the config file disables the
# the loading of custom facts in facter directories under the $LOAD_PATH
test_name "C100004: config file option no-custom-facts : true does not load $LOAD_PATH facter directories" do
  confine :except, :platform => 'cisco_nexus' # see BKR-749
  tag 'risk:high'

  require 'puppet/acceptance/common_utils'
  extend Puppet::Acceptance::CommandUtils

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
    step("Agent #{agent}: determine the load path and create a custom facter directory on it and a config file") do
      ruby_path = on(agent, "#{ruby_command(agent)} -e 'puts $LOAD_PATH[0]'").stdout.chomp
      load_path_facter_dir = File.join(ruby_path, 'facter')
      agent.mkdir_p(load_path_facter_dir)
      custom_fact = File.join(load_path_facter_dir, 'custom_fact.rb')
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
        agent.rm_rf(load_path_facter_dir)
        agent.rm_rf(config_dir)
      end

      step("Agent #{agent}: using config no-custom-facts : true should not resolve facts in facter directories on the $LOAD_PATH") do
        on(agent, facter("--config \"#{config_file}\" custom_fact")) do |facter_output|
          assert_equal("", facter_output.stdout.chomp, "Custom fact in $LOAD_PATH/facter should not have resolved")
        end
      end
    end
  end
end
