# frozen_string_literal: true

module Facter
  module Resolvers
    module Windows
      class Networking < BaseResolver
        @log = Facter::Log.new(self)
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_network_information(fact_name) }
          end

          def read_network_information(fact_name)
            require_relative '../../../facter/resolvers/windows/ffi/networking_ffi'

            size_ptr = FFI::MemoryPointer.new(NetworkingFFI::BUFFER_LENGTH)
            adapter_addresses = FFI::MemoryPointer.new(IpAdapterAddressesLh.size, NetworkingFFI::BUFFER_LENGTH)
            flags = NetworkingFFI::GAA_FLAG_SKIP_ANYCAST |
                    NetworkingFFI::GAA_FLAG_SKIP_MULTICAST | NetworkingFFI::GAA_FLAG_SKIP_DNS_SERVER

            return unless (adapter_addresses = get_adapter_addresses(size_ptr, adapter_addresses, flags))

            iterate_list(adapter_addresses)

            Facter::Util::Resolvers::Networking.expand_main_bindings(@fact_list)

            @fact_list[fact_name]
          end

          def get_adapter_addresses(size_ptr, adapter_addresses, flags)
            error = nil
            3.times do
              error = NetworkingFFI::GetAdaptersAddresses(NetworkingFFI::AF_UNSPEC, flags,
                                                          FFI::Pointer::NULL, adapter_addresses, size_ptr)
              break if error == NetworkingFFI::ERROR_SUCCES

              if error == NetworkingFFI::ERROR_BUFFER_OVERFLOW
                adapter_addresses = FFI::MemoryPointer.new(IpAdapterAddressesLh.size, NetworkingFFI::BUFFER_LENGTH)
              else
                @log.debug 'Unable to retrieve networking facts!'
                return nil
              end
            end
            return nil unless error.zero?

            adapter_addresses
          end

          def adapter_down?(adapter)
            adapter[:OperStatus] != NetworkingFFI::IF_OPER_STATUS_UP ||
              ![NetworkingFFI::IF_TYPE_ETHERNET_CSMACD, NetworkingFFI::IF_TYPE_IEEE80211].include?(adapter[:IfType])
          end

          def retrieve_dhcp_server(adapter)
            if !(adapter[:Flags] & NetworkingFFI::IP_ADAPTER_DHCP_ENABLED).zero? &&
               adapter[:Union][:Struct][:Length] >= IpAdapterAddressesLh.size
              NetworkUtils.address_to_string(adapter[:Dhcpv4Server])
            end
          end

          def iterate_list(adapter_addresses)
            net_interface = {}
            IpAdapterAddressesLh.read_list(adapter_addresses) do |adapter_address|
              if adapter_down?(adapter_address)
                adapter_address = IpAdapterAddressesLh.new(adapter_address[:Next])
                next
              end
              @fact_list[:domain] ||= adapter_address[:DnsSuffix].read_wide_string_without_length
              name = adapter_address[:FriendlyName].read_wide_string_without_length
              net_interface[name] = build_interface_info(adapter_address, name)
            end

            @fact_list[:interfaces] = net_interface unless net_interface.empty?
          end

          def build_interface_info(adapter_address, name)
            hash = {}

            hash[:dhcp] = retrieve_dhcp_server(adapter_address)
            hash[:mtu] = adapter_address[:Mtu]

            bindings = find_ip_addresses(adapter_address[:FirstUnicastAddress], name)
            hash[:bindings] = bindings[:ipv4] unless bindings[:ipv4].empty?
            hash[:bindings6] = bindings[:ipv6] unless bindings[:ipv6].empty?
            hash[:mac] = NetworkUtils.find_mac_address(adapter_address)
            hash
          end

          def find_ip_addresses(unicast_addresses, name)
            bindings = {}
            bindings[:ipv6] = []
            bindings[:ipv4] = []

            IpAdapterUnicastAddressLH.read_list(unicast_addresses) do |unicast|
              addr = NetworkUtils.address_to_string(unicast[:Address])
              unless addr
                unicast = IpAdapterUnicastAddressLH.new(unicast[:Next])
                next
              end

              sock_addr = SockAddr.new(unicast[:Address][:lpSockaddr])
              add_ip_data(addr, unicast, sock_addr, bindings)
              find_primary_interface(sock_addr, name, addr)
            end
            bindings
          end

          def add_ip_data(addr, unicast, sock_addr, bindings)
            result = find_bindings(sock_addr, unicast, addr)
            return unless result

            bindings[:ipv6] << result if sock_addr[:sa_family] == NetworkingFFI::AF_INET6
            bindings[:ipv4] << result if sock_addr[:sa_family] == NetworkingFFI::AF_INET
          end

          def find_bindings(sock_addr, unicast, addr)
            return unless [NetworkingFFI::AF_INET, NetworkingFFI::AF_INET6].include?(sock_addr[:sa_family])

            Facter::Util::Resolvers::Networking.build_binding(addr, unicast[:OnLinkPrefixLength])
          end

          def find_primary_interface(sock_addr, name, addr)
            if !@fact_list[:primary_interface] &&
               ([NetworkingFFI::AF_INET, NetworkingFFI::AF_INET6].include?(sock_addr[:sa_family]) &&
               !::Facter::Util::Resolvers::Networking.ignored_ip_address(addr))
              @fact_list[:primary_interface] = name.to_s
            end
          end
        end
      end
    end
  end
end
