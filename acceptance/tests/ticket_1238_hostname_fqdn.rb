test_name 'C93827: facter fqdn should return the hostname when its a fully qualified domain name' do
  tag 'risk:high'

  confine :except, :platform => 'windows'

  fqdn = 'foo.bar.example.org'

  agents.each do |agent|
    orig_hostname = on(agent, 'hostname').stdout.chomp

    teardown do
      step 'restore original hostname' do
        on(agent, "hostname #{orig_hostname}")
      end
    end

    step "set hostname as #{fqdn}" do
      on(agent, "hostname #{fqdn}")
      sleep 1 # on Solaris 11 hostname returns before the hostname is updated
    end

    step 'validate facter uses hostname as the fqdn if its a fully qualified domain name' do
      on(agent, 'facter fqdn') do |facter_output|
        assert_equal(fqdn, facter_output.stdout.chomp, 'facter did not return the hostname set by the test')
      end
    end
  end
end
