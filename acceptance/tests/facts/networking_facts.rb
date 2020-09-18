test_name 'C59029: networking facts should be fully populated' do
  tag 'risk:high'

#
# This test is intended to ensure that networking facts resolves
# as expected across supported platforms.
#

  @ip_regex       = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  @netmask_regex  = /^(((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(0|128|192|224|240|248|252|254)\.0\.0)|(255\.255\.(0|128|192|224|240|248|252|254)\.0)|(255\.255\.255\.(0|128|192|224|240|248|252|254)))$/

  expected_networking = {
      "networking.dhcp"     => agent['platform'] =~ /fedora-32|el-8-aarch64/ ? '' : @ip_regex, # https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/426
      "networking.ip"       => @ip_regex,
      "networking.ip6"      => /[a-f0-9]+:+/,
      "networking.mac"      => /[a-f0-9]{2}:/,
      "networking.mtu"      => /\d+/,
      "networking.netmask"  => @netmask_regex,
      "networking.netmask6" => /[a-f0-9]+:/,
      "networking.network"  => @ip_regex,
      "networking.network6" => /([a-f0-9]+)?:([a-f0-9]+)?/
  }

  agents.each do |agent|
    primary_interface = fact_on(agent, 'networking.primary')
    refute_empty(primary_interface)

    expected_bindings = {
        "networking.interfaces.#{primary_interface}.bindings.0.address" => @ip_regex,
        "networking.interfaces.#{primary_interface}.bindings.0.netmask" => @netmask_regex,
        "networking.interfaces.#{primary_interface}.bindings.0.network" => @ip_regex,
        "networking.interfaces.#{primary_interface}.bindings6.0.address" => /[a-f0-9:]+/,
        "networking.interfaces.#{primary_interface}.bindings6.0.netmask" => /[a-f0-9:]+/,
        "networking.interfaces.#{primary_interface}.bindings6.0.network" => /[a-f0-9:]+/
    }

    if agent['platform'] =~ /eos|solaris|aix|cisco/
      #remove the invalid networking facts on eccentric platforms
      expected_networking.delete("networking.ip6")
      expected_networking.delete("networking.netmask6")
      expected_networking.delete("networking.network6")

      #remove invalid bindings for the primary networking interface eccentric platforms
      expected_bindings.delete("networking.interfaces.#{primary_interface}.bindings6.0.address")
      expected_bindings.delete("networking.interfaces.#{primary_interface}.bindings6.0.netmask")
      expected_bindings.delete("networking.interfaces.#{primary_interface}.bindings6.0.network")
    end

    if agent['platform'] =~ /aix|sparc|cisco|huawei|sles|s390x/
      # some of our testing platforms do not use DHCP
      expected_networking.delete("networking.dhcp")
    end

    if agent['platform'] =~ /cisco/
      # Cisco main interface does not define netmask or network
      expected_networking.delete("networking.network")
      expected_networking.delete("networking.netmask")

      #remove invalid bindings for Cisco's primary networking interface
      expected_bindings.delete("networking.interfaces.#{primary_interface}.bindings.0.netmask")
      expected_bindings.delete("networking.interfaces.#{primary_interface}.bindings.0.network")
    end

    step "Ensure the Networking fact resolves with reasonable values for at least one interface" do
      expected_networking.each do |fact, value|
        assert_match(value, fact_on(agent, fact).to_s)
      end
    end

    step "Ensure bindings for the primary networking interface are present" do
      expected_bindings.each do |fact, value|
        assert_match(value, fact_on(agent, fact).to_s)
      end
    end
  end

  # Verify that IP Address v6 and network v6 is retrieved correctly and does not contain the interface identifier
  agents.each do |agent|
    if agent['platform'] =~ /windows/
      step("verify that ipaddress6 is retrieved correctly") do
        on(agent, facter("ipaddress6")) do |facter_result|
          assert_match(/^[a-fA-F0-9:]+$/, facter_result.stdout.chomp)
        end
      end

      step("verify that network6 is retrieved correctly") do
        on(agent, facter("network6")) do |facter_result|
          assert_match(/([a-fA-F0-9:]+)?:([a-fA-F0-9:]+)?$/, facter_result.stdout.chomp)
        end
      end
    end
  end
end
