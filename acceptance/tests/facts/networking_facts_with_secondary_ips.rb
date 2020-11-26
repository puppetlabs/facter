test_name 'networking facts with secondary ip' do
  tag 'risk:high'

  confine :except, :platform => 'windows'
  confine :except, :platform => 'aix'
  confine :except, :platform => 'osx'
  confine :except, :platform => 'solaris'
  #
  # This test is intended to ensure that networking facts resolve secondary ips
  # as expected across supported platforms.
  #

  @ip_regex       = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  @netmask_regex  = /^(((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(0|128|192|224|240|248|252|254)\.0\.0)|(255\.255\.(0|128|192|224|240|248|252|254)\.0)|(255\.255\.255\.(0|128|192|224|240|248|252|254)))$/

  def expected_interfaces(interface, count)
    expected_interfaces = {}
    (1..count).each do |index|
      expected_interfaces.merge!(expected_bindings(ip_name(interface, index), 1))
      expected_interfaces.merge!(
        {
          ['networking', 'interfaces', "#{ip_name(interface, index)}", 'ip'] => @ip_regex,
          ['networking', 'interfaces', "#{ip_name(interface, index)}", 'netmask'] => @netmask_regex,
          ['networking', 'interfaces', "#{ip_name(interface, index)}", 'network'] => @ip_regex
        }
      )
    end
    expected_interfaces
  end

  def expected_bindings(interface, count)
    expected_bindings = {}
    (1..count).each do |index|
      expected_bindings.merge!(
        {
          ['networking', 'interfaces', "#{interface}", 'bindings', index - 1, 'address'] => @ip_regex,
          ['networking', 'interfaces', "#{interface}", 'bindings', index - 1, 'netmask'] => @netmask_regex,
          ['networking', 'interfaces', "#{interface}", 'bindings', index - 1, 'network'] => @ip_regex
        }
      )
    end
    expected_bindings
  end

  def ip_name(interface, index)
    "#{interface}:#{index}"
  end

  agents.each do |agent|
    interface = fact_on(agent, 'networking.primary')

    step "Add secondary ip without labels" do
      on(agent, "ip addr add 11.0.0.0/24 dev #{interface}")
    end

    step "Add two secondary ips with label" do
      on(agent, "ip addr add 11.0.0.1/24 dev #{interface} label #{ip_name(interface, 1)}")
      on(agent, "ip addr add 11.0.0.2/24 dev #{interface} label #{ip_name(interface, 2)}")
    end

    networking_facts = JSON.parse(on(agent, facter('networking --json')).stdout)

    step "Check secondary interfaces are found" do
      expected_interfaces(interface, 2).each do |fact_tokens, regex|
        assert_match(regex, networking_facts.dig(*fact_tokens).to_s)
      end
    end

    step "Check secondary interfaces are inside the bindings of the primary interface" do
      expected_bindings(interface, 4).each do |fact_tokens, regex|
        assert_match(regex, networking_facts.dig(*fact_tokens).to_s)
      end
    end

    teardown do
      on(agent, "ip addr del 11.0.0.0/24 dev #{interface}")
      # On Ubuntu 16, deleting the first secondary ip, deletes all of them.
      # Next commands may fail, because the ips they attempt to delete, no longer exist.
      on(agent, "ip addr del 11.0.0.1/24 dev #{interface}", :acceptable_exit_codes => [0, 2])
      on(agent, "ip addr del 11.0.0.2/24 dev #{interface}", :acceptable_exit_codes => [0, 2])
    end
  end
end
