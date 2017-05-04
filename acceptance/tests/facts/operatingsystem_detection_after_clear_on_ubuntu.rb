test_name 'C14891: Facter should properly detect operatingsystem on Ubuntu after a Facter.clear' do
  tag 'risk:high'

  confine :to, :platform => /ubuntu/

  require "puppet/acceptance/common_utils"

  script_contents = <<-OS_DETECT
  require 'facter'
  Facter['operatingsystem'].value
  Facter.clear
  exit Facter['operatingsystem'].value == 'Ubuntu'
  OS_DETECT

  agents.each do |agent|
    script_dir = agent.tmpdir('ubuntu')
    script_name = File.join(script_dir, "facter_os_detection_test")
    create_remote_file(agent, script_name, script_contents)

    teardown do
      on(agent, "rm -rf '#{script_dir}'")
    end

    on(agent, "#{Puppet::Acceptance::CommandUtils.ruby_command(agent)} #{script_name}", :acceptable_exit_codes => 0)
  end
end
