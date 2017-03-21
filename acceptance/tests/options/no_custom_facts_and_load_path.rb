# This tests verifies that when --no-custom-facts is used we do not look for
# 'facter' subdirectories in the $LOAD_PATH
#
# Facter searches all directories in the Ruby $LOAD_PATH variable for subdirectories
# named ‘facter’, and loads all Ruby files in those directories.
test_name "C100003: custom fact commandline options --no-custom-facts does not load $LOAD_PATH facter directories" do
  confine :except, :platform => 'cisco_nexus' # see BKR-749
  tag 'risk:low'

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
    step("Agent #{agent}: determine the load path and create a custom facter directory on it") do
      on(agent, "#{ruby_command(agent)} -e 'puts $LOAD_PATH[0]'")
      load_path_facter_dir = File.join(stdout.chomp, 'facter')
      on(agent, "mkdir -p \"#{load_path_facter_dir}\"")
      custom_fact = File.join(load_path_facter_dir, 'custom_fact.rb')
      create_remote_file(agent, custom_fact, content)

      teardown do
        on(agent, "rm -rf '#{load_path_facter_dir}'")
      end

      step("Agent #{agent}: using --no-custom-facts should not resolve facts on the $LOAD_PATH") do
        on(agent, facter("--no-custom-facts custom_fact")) do
          assert_equal("", stdout.chomp, "Output of the custom fact in a $LOAD_PATH/facter directory should not be resolved, but resolved as #{stdout.chomp}")
        end
      end
    end
  end
end
