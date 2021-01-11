# frozen_string_literal: true

module Facter
  module Resolvers
    class NetworkingLinux < BaseResolver
      init_resolver

      DIRS = ['/var/lib/dhclient/', '/var/lib/dhcp/', '/var/lib/dhcp3/', '/var/lib/NetworkManager/', '/var/db/'].freeze
      ROUTE_TYPES = %w[anycast
                       unicast
                       broadcast
                       local
                       nat
                       unreachable
                       prohibit
                       blackhole
                       throw].freeze

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_network_info(fact_name) }

          @fact_list[fact_name]
        end

        def retrieve_network_info(fact_name)
          mtu_and_indexes = interfaces_mtu_and_index
          retrieve_interfaces_with_socket(mtu_and_indexes)
          add_info_from_routing_table
          retrieve_primary_interface
          Facter::Util::Resolvers::Networking.expand_main_bindings(@fact_list)
          @fact_list[fact_name]
        end

        def interfaces_mtu_and_index
          mtu_and_indexes = {}
          output = Facter::Core::Execution.execute('ip link show', logger: log)
          output.each_line do |line|
            next unless line.include?('mtu')

            parse_ip_command_line(line, mtu_and_indexes)
          end
          log.debug("Associated MTU and index in ip command: #{mtu_and_indexes}")
          mtu_and_indexes
        end

        def parse_ip_command_line(line, mtu_and_indexes)
          mtu = line.match(/mtu (\d+)/)&.captures&.first&.to_i
          index_tokens = line.split(':')
          index = index_tokens[0].strip
          # vlans are displayed as <vlan_name>@<physical_interface>
          name = index_tokens[1].split('@').first.strip
          mtu_and_indexes[name] = { index: index, mtu: mtu }
        end

        def retrieve_interfaces_with_socket(mtu_and_indexes)
          require 'socket'
          interfaces = {}
          Socket.getifaddrs.each do |ifaddr|
            populate_interface_info(ifaddr, interfaces, mtu_and_indexes)
          end

          @fact_list[:interfaces] = interfaces
        end

        def populate_interface_info(ifaddr, interfaces, mtu_and_indexes)
          interface_name = ifaddr.name
          interfaces[interface_name] = {} if interfaces[interface_name].nil?
          interface_data = interfaces[interface_name]

          mac(ifaddr, interfaces)
          mtu(ifaddr, interfaces, mtu_and_indexes)
          ip, netmask, ipv4_type = ip_info_of(ifaddr)
          add_binding(interface_data, interface_name, ip, netmask, ipv4_type)
          dhcp(interface_name, mtu_and_indexes[interface_name], interface_data) if interface_data[:dhcp].nil?
          log.debug("Found interface #{interface_name} with #{interface_data}")
        end

        def mac(ifaddr, interfaces)
          return unless interfaces[ifaddr.name][:mac].nil?

          mac = search_for_mac(ifaddr)
          interfaces[ifaddr.name][:mac] = mac if mac
        end

        def search_for_mac(ifaddr)
          mac = mac_from_bonded_interface(ifaddr.name)
          mac ||= mac_from(ifaddr)
          mac if !mac.nil? && mac != '00:00:00:00:00:00' && mac =~ /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/
        end

        def mac_from_bonded_interface(interface_name)
          master = bond_master_of(interface_name)
          return unless master

          output = Facter::Util::FileHelper.safe_read("/proc/net/bonding/#{master}", nil)
          return unless output

          found_match = false
          output.each_line do |line|
            if line.strip == "Slave Interface: #{interface_name}"
              found_match = true
            elsif line.include? 'Slave Interface'
              # if we reached the data block of another interface belonging to the bonded interface
              found_match = false
            end
            return Regexp.last_match(1) if found_match && line =~ /Permanent HW addr: (\S*)/
          end
        end

        def bond_master_of(interface_name)
          content = Facter::Core::Execution.execute("ip link show #{interface_name}", logger: log)
          content.match(/master (\S*) /)&.captures&.first
        end

        def mac_from(ifaddr)
          if Socket.const_defined? :PF_LINK
            ifaddr.addr&.getnameinfo&.first # sometimes it returns localhost or ip
          elsif Socket.const_defined? :PF_PACKET
            return if ifaddr.addr.nil?

            search_mac_in_sockaddr(ifaddr)
          end
        rescue StandardError => e
          log.debug("Could not read mac, got #{e}")
        end

        def search_mac_in_sockaddr(ifaddr)
          result = ifaddr.addr.inspect_sockaddr
          result&.match(/hwaddr=([\h:]+)/)&.captures&.first
        end

        def mtu(ifaddr, interfaces, mtu_and_indexes)
          return unless interfaces[ifaddr.name][:mtu].nil?

          mtu = mtu_and_indexes.dig(ifaddr.name, :mtu)
          interfaces[ifaddr.name][:mtu] = mtu unless mtu.nil?
        end

        def ip_info_of(ifaddr)
          return if ifaddr.addr.nil? || ifaddr.netmask.nil?

          # ipv6 ips are retrieved as <ip>%<interface_name>
          ip = ifaddr.addr.ip_address.split('%').first
          netmask = ifaddr.netmask.ip_address
          [ip, netmask, ifaddr.addr.ipv4?]
        rescue StandardError => e
          log.debug("Could not read binding data, got #{e}")
        end

        def add_binding(interface_data, interface_name, ip, netmask, ip_v4_type)
          binding = Facter::Util::Resolvers::Networking.build_binding(ip, netmask)
          return if binding.nil?

          log.debug("Adding to interface #{interface_name}, binding:\n#{binding}")
          binding_key = ip_v4_type == true ? :bindings : :bindings6
          interface_data[binding_key] = [] if interface_data[binding_key].nil?
          interface_data[binding_key] << binding
        end

        def add_info_from_routing_table
          routes4, routes6 = read_routing_table
          compare_ips(routes4, :bindings)
          compare_ips(routes6, :bindings6)
        end

        def read_routing_table
          ipv4_output = Facter::Core::Execution.execute('ip route show', logger: log)
          ipv6_output = Facter::Core::Execution.execute('ip -6 route show', logger: log)
          routes4 = parse_routes(ipv4_output, true)
          routes6 = parse_routes(ipv6_output, false)
          [routes4, routes6]
        end

        def parse_routes(output, ipv4_type)
          routes = []
          output.each_line do |line|
            parts = line.split(' ').compact
            next if parts.include?('linkdown')

            delete_invalid_route_type(parts)
            next if !ipv4_type && !parts[0].include?(':')

            route = construct_route(parts)
            routes << route unless route[:ip].nil?
          end
          routes.uniq
        end

        def delete_invalid_route_type(parts)
          route_type = parts[0]
          parts.delete_at(0) if ROUTE_TYPES.include?(route_type)
        end

        def construct_route(parts)
          route = {}
          dev_index = parts.find_index { |elem| elem == 'dev' }
          src_index = parts.find_index { |elem| elem == 'src' }
          route[:interface] = parts[dev_index + 1] if dev_index
          route[:ip] = parts[src_index + 1] if src_index
          route
        end

        def compare_ips(routes, binding_key)
          routes.each do |route|
            next unless @fact_list[:interfaces].key?(route[:interface])

            interface_data = @fact_list[:interfaces][route[:interface]]
            add_binding_if_missing(interface_data, binding_key, route)
          end
        end

        def add_binding_if_missing(interface_data, binding_key, route)
          interface_binding = interface_data[binding_key]

          if interface_binding.nil?
            interface_data[binding_key] = [{ address: route[:ip] }]
          elsif interface_binding.none? { |binding| binding[:address] == route[:ip] }
            interface_binding << { address: route[:ip] }
          end
        end

        def dhcp(interface_name, index_and_mtu, interface_data)
          log.debug("Get DHCP for interface #{interface_name}")

          search_systemd_netif_leases(interface_data, index_and_mtu)
          search_dhclient_leases(interface_data, interface_name)
          search_internal_leases(interface_data, interface_name)
          search_with_dhcpcd_command(interface_data, interface_name)
        end

        def search_systemd_netif_leases(interface_data, index_and_mtu)
          return if index_and_mtu.nil?

          index = index_and_mtu[:index]
          file_content = Facter::Util::FileHelper.safe_read("/run/systemd/netif/leases/#{index}", nil)
          dhcp = file_content.match(/SERVER_ADDRESS=(.*)/) if file_content
          interface_data[:dhcp] = dhcp[1] if dhcp
        end

        def search_dhclient_leases(interface_data, interface_name)
          return unless interface_data[:dhcp].nil?

          DIRS.each do |dir|
            next unless File.readable?(dir)

            lease_files = Dir.entries(dir).select { |file| file =~ /dhclient.*\.lease/ }
            next if lease_files.empty?

            lease_files.select do |file|
              content = Facter::Util::FileHelper.safe_read("#{dir}#{file}", nil)
              next unless content =~ /interface.*#{interface_name}/

              dhcp = content.match(/dhcp-server-identifier ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/)
              return interface_data[:dhcp] = dhcp[1] if dhcp
            end
          end
        end

        def search_internal_leases(interface_data, interface_name)
          return if !interface_data[:dhcp].nil? || !File.readable?('/var/lib/NetworkManager/')

          files = Dir.entries('/var/lib/NetworkManager/').reject { |dir| dir =~ /^\.+$/ }
          lease_file = files.find { |file| file =~ /internal.*#{interface_name}\.lease/ }
          return unless lease_file

          dhcp = Facter::Util::FileHelper.safe_read("/var/lib/NetworkManager/#{lease_file}", nil)

          return unless dhcp

          dhcp = dhcp.match(/SERVER_ADDRESS=(.*)/)
          interface_data[:dhcp] = dhcp[1] if dhcp
        end

        def search_with_dhcpcd_command(interface_data, interface_name)
          return unless interface_data[:dhcp].nil?

          output = Facter::Core::Execution.execute("dhcpcd -U #{interface_name}", logger: log)
          dhcp = output.match(/dhcp_server_identifier='(.*)'/)
          interface_data[:dhcp] = dhcp[1] if dhcp
        end

        def retrieve_primary_interface
          primary_helper = Facter::Util::Resolvers::Networking::PrimaryInterface
          primary_interface = primary_helper.read_from_proc_route
          primary_interface ||= primary_helper.read_from_ip_route
          primary_interface ||= primary_helper.find_in_interfaces(@fact_list[:interfaces])

          @fact_list[:primary_interface] = primary_interface
        end
      end
    end
  end
end
