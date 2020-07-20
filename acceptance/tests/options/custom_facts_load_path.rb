# This test verifies that we can load a custom fact using the ruby $LOAD_PATH variable
#
# Facter searches all directories in the Ruby $LOAD_PATH variable for subdirectories
# named ‘facter’, and loads all Ruby files in those directories.
test_name "C14777: custom facts loaded from facter subdirectory found in $LOAD_PATH directory" do
  confine :except, :platform => 'cisco_nexus' # see BKR-749

  tag 'risk:high'

  require 'puppet/acceptance/common_utils'
  extend Puppet::Acceptance::CommandUtils

  require 'facter/acceptance/user_fact_utils'
  extend Facter::Acceptance::UserFactUtils

  content = <<EOM
Facter.add('custom_fact') do
  setcode do
    "load_path"
  end
end
EOM

  agents.each do |agent|
    step "Agent #{agent}: determine $LOAD_PATH and create custom fact" do
      on(agent, "#{ruby_command(agent)} -e 'puts $LOAD_PATH[0]'")
      load_path_facter_dir = File.join(stdout.chomp, 'facter')
      agent.mkdir_p(load_path_facter_dir)
      custom_fact = File.join(load_path_facter_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)

      teardown do
        agent.rm_rf(load_path_facter_dir)
      end

      step("Agent #{agent}: resolve the custom fact that is in a facter directory on the $LOAD_PATH")
      on(agent, facter("custom_fact")) do |facter_output|
        assert_equal("load_path", facter_output.stdout.chomp, "Incorrect custom fact value for fact in $LOAD_PATH/facter")
      end
    end
  end
end
