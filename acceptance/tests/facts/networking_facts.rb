test_name 'FACT-1361 - C59029 networking facts should be fully populated'

#
# This test is intended to ensure that networking facts resolves
# as expected in AIO across supported platforms.
#

skip_test "Networking fact test is confined to AIO" if @options[:type] != 'aio'

@ip_regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/

expected_networking = {
    "networking.dhcp"     => @ip_regex,
    "networking.ip"       => @ip_regex,
    "networking.ip6"      => /[a-f0-9]+:+/,
    "networking.mac"      => /[a-f0-9]{2}:/,
    "networking.mtu"      => /\d+/,
    "networking.netmask"  => /\d+\.\d+\.\d+\.\d+/,
    "networking.netmask6" => /[a-f0-9]+:/,
    "networking.network"  => @ip_regex,
    "networking.network6" => /([a-f0-9]+)?:([a-f0-9]+)?/
}

agents.each do |agent|

  step "Ensure a primary networking interface was determined."
  primary_interface = fact_on(agent, 'networking.primary')
  refute_empty(primary_interface)

  expected_bindings = {
      "\"networking.interfaces.#{primary_interface}.bindings.0.address\"" => /\d+\.\d+\.\d+\.\d+/,
      "\"networking.interfaces.#{primary_interface}.bindings.0.netmask\"" => /\d+\.\d+\.\d+\.\d+/,
      "\"networking.interfaces.#{primary_interface}.bindings.0.network\"" => /\d+\.\d+\.\d+\.\d+/,
      "\"networking.interfaces.#{primary_interface}.bindings6.0.address\"" => /[a-f0-9:]+/,
      "\"networking.interfaces.#{primary_interface}.bindings6.0.netmask\"" => /[a-f0-9:]+/,
      "\"networking.interfaces.#{primary_interface}.bindings6.0.network\"" => /[a-f0-9:]+/
  }

  case agent['platform']
    when /solaris/, /eos/
      #remove the invalid networking facts on aix and solaris
      expected_networking.delete("networking.ip6")
      expected_networking.delete("networking.netmask6")
      expected_networking.delete("networking.network6")

      #remove invalid bindings for the primary networking interface on AIX and Solaris
      expected_bindings.delete("\"networking.interfaces.#{primary_interface}.bindings6.0.address\"")
      expected_bindings.delete("\"networking.interfaces.#{primary_interface}.bindings6.0.netmask\"")
      expected_bindings.delete("\"networking.interfaces.#{primary_interface}.bindings6.0.network\"")

    when /sparc/, /aix/, /cisco/
      #remove the invalid networking facts on SPARC or AIX
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

  step "Ensure the Networking fact resolves with reasonable values for at least one interface"
  expected_networking.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

  step "Ensure bindings for the primary networking interface are present."
  expected_bindings.each do |fact, value|
    assert_match(value, fact_on(agent, fact))
  end

end
