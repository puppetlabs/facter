test_name "Custom facts should not hang Facter when using win32ole"

confine :to, :platform => /windows/
require 'timeout'

content = <<EOM
Facter.add('custom_fact') do
  setcode do
    require 'win32ole'
    locator = WIN32OLE.new('WbemScripting.SWbemLocator')
    locator.ConnectServer('', "root/CIMV2", '', '', nil, nil, nil, nil).to_s
  end
end
EOM

agents.each do |agent|
  custom_dir = agent.tmpdir('arbitrary_dir')
  custom_fact = File.join(custom_dir, 'custom_fact.rb')
  create_remote_file(agent, custom_fact, content)

  # Test is assumed to have hung if it takes longer than 5 seconds.
  Timeout::timeout(5) do
    on agent, facter('--custom-dir', custom_dir, 'custom_fact') do
      assert_match(/#<WIN32OLE:0x[0-9a-f]+>/, stdout.chomp, 'Custom fact output does not match expected output')
    end
  end
end
