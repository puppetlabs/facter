module Facter
  module Networking
    class << self
      # Creates a hash with IP, netmask and network. Works for IPV4 and IPV6
      # @param [String] addr The IP address
      # @param [Integer] mask_length Number of 1 bits the netmask has
      #
      # @return [Hash] Hash containing ip address, netmask and network
      def build_binding(addr, mask_length)
        require 'ipaddr'

        ip = IPAddr.new(addr)
        mask_helper = ip.ipv6? ? 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' : '255.255.255.255'
        mask = IPAddr.new(mask_helper).mask(mask_length)

        { address: addr, netmask: mask.to_s, network: ip.mask(mask_length).to_s }
      end
    end
  end
end