test_name 'C59029: networking facts should be fully populated' do
  tag 'risk:high'

  #
  # This test is intended to ensure that networking facts resolve
  # as expected across supported platforms.
  #

  @ip_regex       = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  @netmask_regex  = /^(((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(0|128|192|224|240|248|252|254)\.0\.0)|(255\.255\.(0|128|192|224|240|248|252|254)\.0)|(255\.255\.255\.(0|128|192|224|240|248|252|254)))$/

  expected_networking = {
    %w[networking dhcp] => agent['platform'] =~ /fedora-32|el-8-aarch64/ ? '' : @ip_regex, # https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/426
    %w[networking ip] => @ip_regex,
    %w[networking ip6] => /[a-f0-9]+:+/,
    %w[networking mac] => /[a-f0-9]{2}:/,
    %w[networking mtu] => /\d+/,
    %w[networking netmask] => @netmask_regex,
    %w[networking netmask6] => /[a-f0-9]+:/,
    %w[networking network] => @ip_regex,
    %w[networking network6] => /([a-f0-9]+)?:([a-f0-9]+)?/,
    %w[networking scope6] => /link|host|site|global|compat/
  }

  agents.each do |agent|
    primary_interface = fact_on(agent, 'networking.primary')
    refute_empty(primary_interface)

    expected_bindings = {
      ['networking', 'interfaces', primary_interface, 'bindings', 0, 'address'] => @ip_regex,
      ['networking', 'interfaces', primary_interface, 'bindings', 0, 'netmask'] => @netmask_regex,
      ['networking', 'interfaces', primary_interface, 'bindings', 0, 'network'] => @ip_regex,
      ['networking', 'interfaces', primary_interface, 'bindings6', 0, 'address'] => /[a-f0-9:]+/,
      ['networking', 'interfaces', primary_interface, 'bindings6', 0, 'netmask'] => /[a-f0-9:]+/,
      ['networking', 'interfaces', primary_interface, 'bindings6', 0, 'network'] => /[a-f0-9:]+/,
      ['networking', 'interfaces', primary_interface, 'bindings6', 0, 'scope6'] => /link|host|site|global|compat/
    }

    if agent['platform'] =~ /eos|solaris|aix|cisco/
      #remove the invalid networking facts on eccentric platforms
      expected_networking.delete(%w[networking ip6])
      expected_networking.delete(%w[networking netmask6])
      expected_networking.delete(%w[networking network6])
      expected_networking.delete(%w[networking scope6])

      #remove invalid bindings for the primary networking interface eccentric platforms
      expected_bindings.delete(['networking', 'interfaces', primary_interface,  'bindings6', 0, 'address'])
      expected_bindings.delete(['networking', 'interfaces', primary_interface,  'bindings6', 0, 'netmask'])
      expected_bindings.delete(['networking', 'interfaces', primary_interface,  'bindings6', 0, 'network'])
      expected_bindings.delete(['networking', 'interfaces', primary_interface,  'bindings6', 0, 'scope6'])
    end

    if agent['platform'] =~ /aix|sparc|cisco|huawei|sles|s390x/
      # some of our testing platforms do not use DHCP
      expected_networking.delete(%w[networking dhcp])
    end

    if agent['platform'] =~ /cisco/
      # Cisco main interface does not define netmask or network
      expected_networking.delete(%w[networking network])
      expected_networking.delete(%w[networking netmask])

      #remove invalid bindings for Cisco's primary networking interface
      expected_bindings.delete(['networking', 'interfaces', primary_interface, 'bindings', 0, 'netmask'])
      expected_bindings.delete(['networking', 'interfaces', primary_interface, 'bindings', 0, 'network'])
    end

    networking_facts = JSON.parse(on(agent, facter('networking --json')).stdout)

    step "Ensure the Networking fact resolves with reasonable values for at least one interface" do
      expected_networking.each do |fact_tokens, regex|
        assert_match(regex, networking_facts.dig(*fact_tokens).to_s)
      end
    end

    step "Ensure bindings for the primary networking interface are present" do
      expected_bindings.each do |fact_tokens, regex|
        assert_match(regex, networking_facts.dig(*fact_tokens).to_s)
      end
    end
  end

  # Verify that IP Address v6 and network v6 is retrieved correctly and does not contain the interface identifier
  agents.each do |agent|
    if agent['platform'] =~ /windows/
      step "verify that ipaddress6 is retrieved correctly" do
        on(agent, facter('ipaddress6')) do |facter_result|
          assert_match(/^[a-fA-F0-9:]+$/, facter_result.stdout.chomp)
        end
      end

      step "verify that network6 is retrieved correctly" do
        on(agent, facter('network6')) do |facter_result|
          assert_match(/([a-fA-F0-9:]+)?:([a-fA-F0-9:]+)?$/, facter_result.stdout.chomp)
        end
      end
    end
  end
end
