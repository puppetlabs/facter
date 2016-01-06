platforms = hosts.map{|val| val[:platform]}
skip_test "No arista hosts present" unless platforms.any? { |val| /^eos-/ =~ val }
test_name 'Arista Switch Pre-suite' do
  switchs = select_hosts({:platform => ['eos-4-i386']})

  step 'add puppet user to switch' do
    switchs.each do |switch|
      on(switch, "/opt/puppetlabs/bin/puppet config --confdir /etc/puppetlabs/puppet set user root")
      on(switch, "/opt/puppetlabs/bin/puppet config --confdir /etc/puppetlabs/puppet set group root")
    end
  end
end
