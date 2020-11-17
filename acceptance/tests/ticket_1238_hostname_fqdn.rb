test_name 'C93827: facter fqdn should return the hostname when its a fully qualified domain name' do
  tag 'risk:high'
  require 'timeout'

  confine :except, :platform => 'windows'

  fqdn = 'foo.bar.example.org'
  fqdn_long = 'a23456789.b23456789.c23456789.d23456789.e23456789.f23456789.wxyz'

  agents.each do |agent|
    orig_hostname = on(agent, 'hostname').stdout.chomp

    teardown do
      step 'restore original hostname' do
        on(agent, "hostname #{orig_hostname}")
      end
    end

    step "set hostname as #{fqdn}" do
      on(agent, "hostname #{fqdn}")
      begin
        Timeout.timeout(20) do
          until on(agent, 'hostname').stdout =~ /#{fqdn}/
            sleep(0.25) # on Solaris 11 hostname returns before the hostname is updated
          end
        end
      rescue Timeout::Error
        raise "Failed to reset the hostname of the test machine to #{fqdn}"
      end
    end

    step 'validate facter uses hostname as the fqdn if its a fully qualified domain name' do
      on(agent, "facter fqdn #{@options[:trace]}") do |facter_output|
        assert_equal(fqdn, facter_output.stdout.chomp, 'facter did not return the hostname set by the test')
      end
    end
  end

  step "long hostname as #{fqdn_long}" do
    on(agent, "hostname #{fqdn_long}")
    begin
      Timeout.timeout(20) do
        until on(agent, 'hostname').stdout =~ /#{fqdn_long}/
          sleep(0.25) # on Solaris 11 hostname returns before the hostname is updated
        end
      end
    rescue Timeout::Error
      raise "Failed to reset the hostname of the test machine to #{fqdn_long}"
    end
  end

  step 'validate facter uses hostname as the LONG fqdn if its a fully qualified domain name' do
    on(agent, "facter fqdn #{@options[:trace]}") do |facter_output|
      assert_equal(fqdn_long, facter_output.stdout.chomp, 'facter did not return the hostname set by the test')
    end
  end
end
