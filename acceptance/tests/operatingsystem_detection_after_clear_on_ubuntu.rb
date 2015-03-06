test_name "#7670: Facter should properly detect operatingsystem on Ubuntu after a clear"

script_contents = <<-OS_DETECT
  require 'facter'
  Facter['operatingsystem'].value
  Facter.clear
  exit Facter['operatingsystem'].value == 'Ubuntu'
OS_DETECT

script_name = "/tmp/facter_os_detection_test_#{$$}"

agents.each do |agent|
  next unless agent['platform'].include? 'ubuntu'

  create_remote_file(agent, script_name, script_contents)

  on(agent, "#{agent['privatebindir']}/ruby #{script_name}")
end
