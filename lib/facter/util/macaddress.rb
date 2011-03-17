# A module to gather macaddress facts
#
module Facter::Util::Macaddress

  module Darwin
    def self.macaddress
      iface = default_interface
      Facter.warn "Could not find a default route. Using first non-loopback interface" if iface.empty?

      macaddress = `#{ifconfig_command} #{iface} | /usr/bin/awk '/ether/{print $2;exit}'`.chomp
      macaddress.empty? ? nil : macaddress
    end

    def self.default_interface
      `#{netstat_command} | /usr/bin/awk  '/^default/{print $6;exit}'`.chomp
    end

    private

    def self.netstat_command
      '/usr/sbin/netstat -rn'
    end

    def self.ifconfig_command
      '/sbin/ifconfig'
    end
  end
end
