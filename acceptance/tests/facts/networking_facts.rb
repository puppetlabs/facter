test_name 'FACT-1361 - C59029 networking facts should be fully populated' do

#
# This test is intended to ensure that networking facts resolves
# as expected across supported platforms.
#

  @ip_regex       = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  @netmask_regex  = /^(((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(0|128|192|224|240|248|252|254)\.0\.0)|(255\.255\.(0|128|192|224|240|248|252|254)\.0)|(255\.255\.255\.(0|128|192|224|240|248|252|254)))$/

  expected_networking = {
      "networking.dhcp"     => @ip_regex,
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
    step "Ensure a primary networking interface was determined" do
      primary_interface = fact_on(agent, 'networking.primary')
      refute_empty(primary_interface)

      expected_bindings = {
          "\"networking.interfaces.#{primary_interface}.bindings.0.address\"" => @ip_regex,
          "\"networking.interfaces.#{primary_interface}.bindings.0.netmask\"" => @netmask_regex,
          "\"networking.interfaces.#{primary_interface}.bindings.0.network\"" => @ip_regex,
          "\"networking.interfaces.#{primary_interface}.bindings6.0.address\"" => /[a-f0-9:]+/,
          "\"networking.interfaces.#{primary_interface}.bindings6.0.netmask\"" => /[a-f0-9:]+/,
          "\"networking.interfaces.#{primary_interface}.bindings6.0.network\"" => /[a-f0-9:]+/
      }

      case agent['platform']
        when /solaris/, /eos/
          #remove the invalid networking facts on Solaris or Arista
          expected_networking.delete("networking.ip6")
          expected_networking.delete("networking.netmask6")
          expected_networking.delete("networking.network6")

          #remove invalid bindings for the primary networking interface on AIX and Solaris
          expected_bindings.delete("\"networking.interfaces.#{primary_interface}.bindings6.0.address\"")
          expected_bindings.delete("\"networking.interfaces.#{primary_interface}.bindings6.0.netmask\"")
          expected_bindings.delete("\"networking.interfaces.#{primary_interface}.bindings6.0.network\"")

        when /sparc/, /aix/, /cisco/
          #remove the invalid networking facts on SPARC, AIX, or Cisco
          #Our SPARC testing platforms don't use DHCP
          expected_networking.delete("networking.dhcp")
          expected_networking.delete("networking.ip6")
          expected_networking.delete("networking.netmask6")
          expected_networking.delete("networking.network6")

          #remove invalid bindings for the primary networking interface on SPARC or AIX
          expected_bindings.delete("\"networking.interfaces.#{primary_interface}.bindings6.0.address\"")
          expected_bindings.delete("\"networking.interfaces.#{primary_interface}.bindings6.0.netmask\"")
          expected_bindings.delete("\"networking.interfaces.#{primary_interface}.bindings6.0.network\"")

        when /sles/
          #some sles VMs do not have networking.dhcp
          expected_networking.delete("networking.dhcp")

      end
    end

    step "Ensure the Networking fact resolves with reasonable values for at least one interface" do
      expected_networking.each do |fact, value|
        assert_match(value, fact_on(agent, fact))
      end
    end

    step "Ensure bindings for the primary networking interface are present" do
      expected_bindings.each do |fact, value|
        assert_match(value, fact_on(agent, fact))
      end
    end
  end
end
