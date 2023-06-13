test_name 'networking facts with vlans' do
  tag 'risk:high'

  confine :except, :platform => 'windows'
  confine :except, :platform => 'aix'
  confine :except, :platform => 'osx'
  confine :except, :platform => 'solaris'
  # skip_test "FACT-3204 skip test due to issue with ubuntu 2204 image"  if hosts.any? { |host| host['platform'] =~ /ubuntu-22\.04/ }

  #
  # This test is intended to ensure that networking facts resolve vlans
  # as expected across supported platforms.
  #
  teardown do
    agents.each do |agent|
      interface = fact_on(agent, 'networking.primary')
      on(agent, "ip link delete #{vlan(interface, 1)}", accept_all_exit_codes: true)
      on(agent, "ip link delete #{vlan(interface, 2)}", accept_all_exit_codes: true)
    end
  end

  @ip_regex       = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  @netmask_regex  = /^(((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(0|128|192|224|240|248|252|254)\.0\.0)|(255\.255\.(0|128|192|224|240|248|252|254)\.0)|(255\.255\.255\.(0|128|192|224|240|248|252|254)))$/

  def vlan(interface, index)
    "#{interface}.#{index}"
  end

  def expected_bindings(interface, count)
    expected_bindings = {}
    (1..count).each do |index|
      expected_bindings.merge!(
        {
          ['networking', 'interfaces', vlan(interface, index).to_s, 'bindings', 0, 'address'] => @ip_regex,
          ['networking', 'interfaces', vlan(interface, index).to_s, 'bindings', 0, 'netmask'] => @netmask_regex,
          ['networking', 'interfaces', vlan(interface, index).to_s, 'bindings', 0, 'network'] => @ip_regex,
          %W[networking interfaces #{vlan(interface, index)} ip] => @ip_regex,
          %W[networking interfaces #{vlan(interface, index)} mac] => /[a-f0-9]{2}:/,
          %W[networking interfaces #{vlan(interface, index)} mtu] => /\d+/,
          %W[networking interfaces #{vlan(interface, index)} netmask] => @netmask_regex,
          %W[networking interfaces #{vlan(interface, index)} network] => @ip_regex
        }
      )
    end
    expected_bindings
  end

  agents.each do |agent|
    operating_system = fact_on(agent, 'operatingsystem')
    release = fact_on(agent, 'operatingsystemrelease')

    if operating_system == 'Amazon' && release == '2017.03'
      skip_test 'Not able to create VLANs on Amazon 6'
    end

    interface = fact_on(agent, 'networking.primary')

    step "Add two vlans" do
      on(agent, "ip link add link #{interface} name #{vlan(interface, 1)} type vlan id 1")
      on(agent, "ip addr add 11.0.0.1/24 dev #{vlan(interface, 1)}")
      if on(agent, "ip address show #{vlan(interface, 1)} | grep inet[[:space:]]", acceptable_exit_codes: [0,1]).stdout.empty?
        @logger.warn("Attempted to update #{vlan(interface, 1)} but ipv4 address not found, outputting recent syslog and retrying.")
        on(agent, 'tail /var/log/syslog')
        on(agent, "ip addr add 11.0.0.1/24 dev #{vlan(interface, 1)}")
        fail_test("Unable to update ip address for #{vlan(interface, 1)}") if on(agent, "ip address show #{vlan(interface, 1)} | grep inet[[:space:]]").stdout.empty?
      end
      on(agent, "ip link add link #{interface} name #{vlan(interface, 2)} type vlan id 2")
      on(agent, "ip addr add 11.0.0.2/24 dev #{vlan(interface, 2)}")
    end

    step "Check vlans are found" do
      networking_facts = JSON.parse(on(agent, facter('networking --json')).stdout)

      expected_bindings(interface, 2).each do |fact_tokens, regex|
        assert_match(regex, networking_facts.dig(*fact_tokens).to_s)
      end
    end

  end
end
