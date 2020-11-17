test_name 'Querying the fqdn with a numeric hostname should not fail' do

  # calling getaddrinfo with a numeric value on OS X does not fill the
  # ai_canonname field of the addrinfo structure
  confine :to, :platform => /^osx-/

  agents.each do |agent|
    original_hostname = agent.hostname.split('.').first
    numeric_hostname = 42

    teardown do
      on(agent, "scutil --set HostName #{original_hostname}")
    end

    step "Change hostname from '#{original_hostname}' to '#{numeric_hostname}'" do
      on(agent, "scutil --set HostName #{numeric_hostname}")
    end

    step 'Verify fqdn fact does not fail' do
      on(agent, facter("fqdn #{@options[:trace]}"))
    end
  end
end
