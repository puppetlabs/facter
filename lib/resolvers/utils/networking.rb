# frozen_string_literal: true

module Resolvers
  module Utils
    module Networking
      class << self
        # Creates a hash with IP, netmask and network. Works for IPV4 and IPV6
        # @param [String] addr The IP address
        # @param [Integer] mask_length Number of 1 bits the netmask has
        #
        # @return [Hash] Hash containing ip address, netmask and network
        def build_binding(addr, mask_length)
          ip = IPAddr.new(addr)
          mask_helper = ip.ipv6? ? 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' : '255.255.255.255'
          mask = IPAddr.new(mask_helper).mask(mask_length)

          { address: addr, netmask: mask.to_s, network: ip.mask(mask_length).to_s }
        end

        def get_scope(ip)
          scope6 = []
          addrinfo = Addrinfo.new(['AF_INET6', 0, nil, ip], :INET6)

          scope6 << 'compat,' if addrinfo.ipv6_v4compat?
          scope6 << if addrinfo.ipv6_linklocal?
                      'link'
                    elsif addrinfo.ipv6_sitelocal?
                      'site'
                    elsif addrinfo.ipv6_loopback?
                      'host'
                    else 'global'
                    end
          scope6.join
        end
      end
    end
  end
end
