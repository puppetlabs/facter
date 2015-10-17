test_name 'ticket 1238 facter should respect hostname if fqdn'

confine :except, :platform => 'windows'

fqdn = 'foo.bar.example.org'

agents.each do |agent|
  orig_hostname = on(agent, 'hostname').stdout.chomp
  teardown do
    step 'restore original hostname' do
      on(agent, "hostname #{orig_hostname}")
    end
  end

  step 'set hostname as fqdn' do
    on(agent, "hostname #{fqdn}")
  end

  step 'validate facter honors fqdn' do
    res = on(agent, 'facter fqdn').stdout.chomp
    assert_equal(fqdn, res, "fqdn hostname #{fqdn} did not match `facter fqdn` #{res}")
  end
end
