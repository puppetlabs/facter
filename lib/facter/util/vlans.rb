# A module to gather vlan facts
#
module Facter::Util::Vlans
  def self.get_vlan_config
    output = ""
      if File.exists?('/proc/net/vlan/config') and File.readable?('/proc/net/vlan/config')
        output = File.open('/proc/net/vlan/config').read
      end
    output
  end

  def self.get_vlans
    vlans = Array.new
    if self.get_vlan_config
      self.get_vlan_config.each_line do |line|
        if line =~ /^([0-9A-Za-z]+)\.([0-9]+) /
          vlans.insert(-1, $~[2]) if $~[2]
        end
      end
    end

    vlans.join(',')
  end
end
