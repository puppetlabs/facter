test_name 'C93827: facter fqdn should return the hostname when its a fully qualified domain name' do
  tag 'risk:high'
  require 'timeout'

  confine :except, :platform => 'windows'

  fqdn_hostname = 'foo'
  fqdn_domain = 'bar.example.org'
  fqdn = "#{fqdn_hostname}.#{fqdn_domain}"

  agents.each do |agent|
    orig_hostname = on(agent, 'hostname').stdout.chomp

    teardown do
      step 'restore original hostname' do
        on(agent, "hostname #{orig_hostname}")
      end
    end

    step "set hostname as #{fqdn}" do
      begin
        if agent['platform'] =~ /^(debian|centos|el|fedora|ubuntu)-/
          on(agent, "hostname #{fqdn_hostname}")
          on(agent, "printf '127.0.1.1 #{fqdn} #{fqdn_hostname}\\n' > /etc/hosts")
        else
          on(agent, "hostname #{fqdn}")
          Timeout.timeout(20) do
            until on(agent, 'hostname').stdout =~ /#{fqdn}/
              sleep(0.25) # on Solaris 11 hostname returns before the hostname is updated
            end
          end
        end
      rescue Timeout::Error
        raise "Failed to reset the hostname of the test machine to #{fqdn}"
      end
    end

    step 'validate facter uses hostname as the fqdn if its a fully qualified domain name' do
      on(agent, 'facter fqdn') do |facter_output|
        assert_equal(fqdn, facter_output.stdout.chomp, 'facter did not return the hostname set by the test')
      end
    end
  end

  fqdn_long_hostname = 'a23456789'
  fqdn_long_domain = 'b23456789.c23456789.d23456789.e23456789.f23456789.wxyz'
  fqdn_long = "#{fqdn_long_hostname}.#{fqdn_long_domain}"

  step "long hostname as #{fqdn_long}" do
    begin
      if agent['platform'] =~ /^(debian|centos|el|fedora|ubuntu)-/
        on(agent, "hostname #{fqdn_long_hostname}")
        on(agent, "printf '127.0.1.1 #{fqdn_long} #{fqdn_long_hostname}\\n' > /etc/hosts")
      else
        on(agent, "hostname #{fqdn_long}")
        Timeout.timeout(20) do
          until on(agent, 'hostname').stdout =~ /#{fqdn_long}/
            sleep(0.25) # on Solaris 11 hostname returns before the hostname is updated
          end
        end
      end
    rescue Timeout::Error
      raise "Failed to reset the hostname of the test machine to #{fqdn_long}"
    end
  end

  step 'validate facter uses hostname as the LONG fqdn if its a fully qualified domain name' do
    on(agent, 'facter fqdn') do |facter_output|
      assert_equal(fqdn_long, facter_output.stdout.chomp, 'facter did not return the hostname set by the test')
    end
  end
end
