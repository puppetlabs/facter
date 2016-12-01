platforms = hosts.map{|val| val[:platform]}
skip_test "No Cisco XR hosts present" unless platforms.any? { |val| /^cisco_ios_xr-/ =~ val }
test_name 'Cisco XR Switch Pre-suite' do
  switchs = select_hosts({:platform => ['cisco_ios_xr-6-x86_64']})

  step 'remove LD_PRELOAD setting from switch' do
    switchs.each do |switch|
      on(switch, "echo 'unset LD_PRELOAD' >> /etc/profile")
    end
  end
end
