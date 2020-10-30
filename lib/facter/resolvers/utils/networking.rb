# frozen_string_literal: true

require 'ipaddr'

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
          return if !addr || !mask_length

          ip = IPAddr.new(addr)
          mask_helper = ip.ipv6? ? 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' : '255.255.255.255'
          mask = IPAddr.new(mask_helper).mask(mask_length)

          { address: addr, netmask: mask.to_s, network: ip.mask(mask_length).to_s }
        end

        def expand_main_bindings(networking_facts)
          primary = networking_facts[:primary_interface]
          interfaces = networking_facts[:interfaces]

          expand_interfaces(interfaces) unless interfaces.nil?
          expand_primary_interface(networking_facts, primary) unless primary.nil? || interfaces.nil?
        end

        def get_scope(ip)
          require 'socket'

          scope6 = []
          addrinfo = Addrinfo.new(['AF_INET6', 0, nil, ip], :INET6)

          scope6 << 'compat,' if IPAddr.new(ip).ipv4_compat?
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

        def find_valid_binding(bindings)
          bindings.each do |binding|
            return binding unless ignored_ip_address(binding[:address])
          end
          bindings.empty? ? nil : bindings.first
        end

        def ignored_ip_address(addr)
          addr.empty? || addr.start_with?('127.', '169.254.') || addr.start_with?('fe80') || addr.eql?('::1')
        end

        private

        def expand_interfaces(interfaces)
          interfaces.each_value do |values|
            expand_binding(values, values[:bindings]) if values[:bindings]
            expand_binding(values, values[:bindings6], false) if values[:bindings6]
          end
        end

        def expand_primary_interface(networking_facts, primary)
          networking_facts[:interfaces][primary].each do |key, value|
            networking_facts[key] = value unless %i[bindings bindings6].include?(key)
          end
        end

        def expand_binding(values, bindings, ipv4_type = true)
          binding = find_valid_binding(bindings)
          ip_protocol_type = ipv4_type ? '' : '6'

          values["ip#{ip_protocol_type}".to_sym] = binding[:address]
          values["netmask#{ip_protocol_type}".to_sym] = binding[:netmask]
          values["network#{ip_protocol_type}".to_sym] = binding[:network]
          values[:scope6] = get_scope(binding[:address]) unless ipv4_type
        end
      end
    end
  end
end
