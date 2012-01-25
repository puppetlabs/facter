# Fact: arp
#
# Purpose: 
# 	   Internal fact used to specity the program to return the arp value.
#
# Resolution: 
# 	   The arp module creates a fact ‘arp’ if and only if the first entry 
#	   in the arptable is “fe:ff:ff:ff:ff:ff”. The output is IP address 
#	   mapped against the MAC address of the machine.
#
# Caveats: 
# 	   Internal fact used to specity the program to detect the arp value only on EC2.
#	   Warning: Fact might in future be deprcated. Refer to ticket #11307.
#
require 'facter/util/ip'

Facter.add(:arp) do
  confine :kernel => :linux
  setcode do
    output = Facter::Util::Resolution.exec('arp -an')
    if not output.nil?
      arp = ""
      output.each_line do |s|
        if s =~ /^\S+\s\S+\s\S+\s(\S+)\s\S+\s\S+\s\S+$/
          arp = $1.downcase
          break # stops on the first match
        end
      end
    end
    "fe:ff:ff:ff:ff:ff" == arp ? arp : nil
  end
end

Facter::Util::IP.get_interfaces.each do |interface|
  Facter.add("arp_" + Facter::Util::IP.alphafy(interface)) do
    confine :kernel => :linux
    setcode do
      arp = Facter::Util::IP.get_arp_value(interface)
      "fe:ff:ff:ff:ff:ff" == arp ? arp : nil
    end
  end
end
