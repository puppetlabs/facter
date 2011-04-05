require 'facter/util/ip'

Facter.add(:arp) do
  confine :kernel => :linux
  setcode do
    output = Facter::Util::Resolution.exec('arp -a')
    if not output.nil?
      arp = ""
      output.each_line do |s|
        if s =~ /^\S+\s\S+\s\S+\s(\S+)\s\S+\s\S+\s\S+$/
          arp = $1
          break # stops on the first match
        end
      end
    end
    EC2_ARP == arp ? arp : nil
  end
end

Facter::Util::IP.get_interfaces.each do |interface|
  Facter.add("arp_" + Facter::Util::IP.alphafy(interface)) do
    confine :kernel => :linux
    setcode do
      arp = Facter::Util::IP.get_arp_value(interface)
      EC2_ARP == arp ? arp : nil
    end
  end
end
