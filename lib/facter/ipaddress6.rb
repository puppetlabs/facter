# Fact: ipaddress6
#
# Purpose: Returns the "main" IPv6 IP address of a system.
#
# Resolution:
#   OS-dependent code that parses the output of various networking
#   tools and currently not very intelligent. Returns the first
#   non-loopback and non-linklocal address found in the ouput unless
#   a default route can be mapped to a routable interface. Guessing
#   an interface is currently only possible with BSD-type systems;
#   too many assumptions have to be made on other platforms to make
#   this work with the current code. Most of this code is ported or
#   modeled after the ipaddress fact for the sake of similar
#   functionality and familiar mechanics.
#
# Caveats:
#

# Cody Herriges <c.a.herriges@gmail.com>
#
# Used the ipaddress fact that is already part of
# Facter as a template.

require 'facter/util/ip'

def get_address_after_token(output, token, return_first=false)
  ip = nil

  String(output).scan(/#{token}\s?((?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/).each do |match|
    match = match.first
    unless match =~ /^fe80.*/ or match == "::1"
      ip = match
      break if return_first
    end
  end

  ip
end

Facter.add(:ipaddress6) do
  confine :kernel => :linux
  setcode do
    output = Facter::Util::IP.exec_ifconfig(["2>/dev/null"])
    get_address_after_token(output, 'inet6(?: addr:)?')
  end
end

Facter.add(:ipaddress6) do
  confine :kernel => %w{SunOS}
  setcode do
    output = Facter::Util::IP.exec_ifconfig(["-a"])

    get_address_after_token(output, 'inet6')
  end
end

Facter.add(:ipaddress6) do
  confine :kernel => %w{Darwin FreeBSD OpenBSD}
  setcode do
    output = Facter::Util::IP.exec_ifconfig(["-a"])

    get_address_after_token(output, 'inet6', true)
  end
end

Facter.add(:ipaddress6) do
  confine :kernel => :windows
  setcode do
    require 'facter/util/ip/windows'
    ipaddr = nil

    adapters = Facter::Util::IP::Windows.get_preferred_ipv6_adapters
    adapters.find do |nic|
      nic.IPAddress.any? do |addr|
        ipaddr = addr if Facter::Util::IP::Windows.valid_ipv6_address?(addr)
        ipaddr
      end
    end

    ipaddr
  end
end
