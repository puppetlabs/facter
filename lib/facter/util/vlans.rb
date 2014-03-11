# A module to gather vlan facts
#
module Facter::Util::Vlans
  def self.get_vlan_config
    if File.exist?('/proc/net/vlan/config') and File.readable?('/proc/net/vlan/config')
      File.read('/proc/net/vlan/config')
    end
  end

  def self.get_vlans
    if (config = self.get_vlan_config)
      vlans = []
      config.each_line do |line|
        if (match = line.match(/^([0-9A-Za-z]+)\.([0-9]+) /))
          vlans << match[2] if match[2]
        end
      end
      vlans.join(',') unless vlans.empty?
    end
  end
end
