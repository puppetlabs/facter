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
          retrieve_interface_info(mtu_and_indexes)
          add_info_from_routing_table
          retrieve_primary_interface
          Facter::Util::Resolvers::Networking.expand_main_bindings(@fact_list)
          @fact_list[fact_name]
        end

        def interfaces_mtu_and_index
          mtu_and_indexes = {}
          output = Facter::Core::Execution.execute("ip link show", logger: log)
          output.each_line do |line|
            next unless line.include?('mtu')

            mtu = line.match(/mtu (\d+)/)&.captures&.first&.to_i
            index_tokens = line.split(':')
            index = index_tokens[0].strip
            # vlans are displayed as <vlan_name>@<physical_interface>
            name = index_tokens[1].split('@').first.strip
            mtu_and_indexes[name] = [index, mtu]
          end
          mtu_and_indexes
        end

        def retrieve_interface_info(mtu_and_indexes)
          require 'socket'
          interfaces = {}
          Socket.getifaddrs.each do |interface|
            interfaces[interface.name] = {} if interfaces[interface.name].nil?

            if interfaces[interface.name][:mac].nil?
              mac = extract_mac_address(interface)
              interfaces[interface.name][:mac] = mac if mac
            end

            if interfaces[interface.name][:mtu].nil?
              mtu = mtu_and_indexes.dig(interface.name, 1)
              interfaces[interface.name][:mtu] = mtu unless mtu.nil?
            end

            if !interface.addr.nil? && !interface.netmask.nil?
              begin
                # ipv6 ips are retrieved as <ip>%<interface_name>
                ip = interface.addr.ip_address.split('%').first if interface.addr.ip?
                netmask = interface.netmask.ip_address
                add_binding(interfaces, interface.name, ip, netmask, interface.addr.ipv4?)
              rescue SocketError => e
              end
            end
            find_dhcp!(interface.name, mtu_and_indexes, interfaces)
          end

          @fact_list[:interfaces] = interfaces
        end

        def extract_mac_address(interface)
          mac = get_bonded_interface_mac(interface.name)
          begin
            if mac.nil?
              if Socket.const_defined? :PF_LINK
                mac = interface.addr&.getnameinfo&.first #sometimes it returns localhost, ip but mac also
              elsif Socket.const_defined? :PF_PACKET
                return if interface.addr.nil? || interface.addr.inspect_sockaddr.nil?

                mac = interface.addr&.inspect_sockaddr[/hwaddr=([\h:]+)/, 1]
              end
            end
          rescue StandardError => e
            log.debug("Could not read mac, got #{e}")
          end
          mac if !mac.nil? && mac != '00:00:00:00:00:00' && mac =~ /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/
        end

        def get_bonded_interface_mac(interface_name)
          master = get_bond_master(interface_name)
          return unless master

          output = Facter::Util::FileHelper.safe_read("/proc/net/bonding/#{master}", nil)
          return unless output

          right_block = false
          output.each_line do |line|
            if line.strip == "Slave Interface: #{interface_name}"
              right_block = true
            elsif line.include? 'Slave Interface'
              right_block = false
            end
            return Regexp.last_match(1) if right_block && line =~ /Permanent HW addr: (\S*)/
          end
        end

        def get_bond_master(interface_name)
          content = Facter::Core::Execution.execute("ip link show #{interface_name}", logger: log)
          master = content.match(/master (\S*) /)
          return master[1] if master

          nil
        end

        def add_binding(interfaces, name, ip, netmask, ip_v4_type)
          binding = Facter::Util::Resolvers::Networking.build_binding(ip, netmask)
          return if binding.nil?

          log.debug("Adding to interface #{name}, binding:\n#{binding}")
          binding_key = ip_v4_type == true ? :bindings : :bindings6
          interfaces[name][binding_key] = [] if interfaces[name][binding_key].nil?
          interfaces[name][binding_key] << binding
        end

        def add_info_from_routing_table
          routes4, routes6 = read_routing_table
          compare_ips(routes4, :bindings)
          compare_ips(routes6, :bindings6)
        end


        def read_routing_table
          ipv4_output = Facter::Core::Execution.execute('ip route show', logger: log)
          ipv6_output = Facter::Core::Execution.execute('ip -6 route show', logger: log)
          routes4 = parse_routes(ipv4_output, 'ipv4')
          routes6 = parse_routes(ipv6_output, 'ipv6')
          [routes4, routes6]
        end

        def parse_routes(output, family)
          routes = []
          output.each_line do |line|
            parts = line.split(' ').compact
            next if parts.include?('linkdown')

            route_type = parts[0]
            parts.delete_at(0) if ROUTE_TYPES.include?(route_type)
            next if family == 'ipv6' && !parts[0].include?(':')

            route = construct_route(parts)
            routes << route unless route[:ip].nil?
          end
          routes.uniq
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
            # TODO we should simplify this
            if @fact_list[:interfaces].key?(route[:interface])
              if @fact_list[:interfaces][route[:interface]][binding_key].nil?
                @fact_list[:interfaces][route[:interface]][binding_key] = [{ address: route[:ip] }]
              elsif @fact_list[:interfaces][route[:interface]][binding_key].none? { |binding| binding[:address] == route[:ip] }
                @fact_list[:interfaces][route[:interface]][binding_key] << { address: route[:ip] }
              end
            end
          end
        end

        def find_dhcp!(interface_name, interface_indexes, interfaces)
          return if !interfaces[interface_name] || interfaces[interface_name][:dhcp]

          log.debug("Get DHCP for interface #{interface_name}")
          unless interface_indexes[interface_name].nil?
            index = interface_indexes[interface_name][0]
            file_content = Facter::Util::FileHelper.safe_read("/run/systemd/netif/leases/#{index}", nil)
            dhcp = file_content.match(/SERVER_ADDRESS=(.*)/) if file_content
            if dhcp
              interfaces[interface_name][:dhcp] = dhcp[1]
            else
              alternate_dhcp = retrieve_from_other_directories(interface_name)
              interfaces[interface_name][:dhcp] = alternate_dhcp if alternate_dhcp
            end
          end
          return unless interfaces[interface_name][:dhcp].nil?

          output = Facter::Core::Execution.execute("dhcpcd -U #{interface_name}", logger: log)
          result = output.match(/dhcp_server_identifier='(.*)'/)&.captures&.first
          interfaces[interface_name][:dhcp] = result if result
        end

        def retrieve_from_other_directories(interface_name)
          DIRS.each do |dir|
            next unless File.readable?(dir)

            lease_files = Dir.entries(dir).select { |file| file =~ /dhclient.*\.lease/ }
            next if lease_files.empty?

            lease_files.select do |file|
              content = Facter::Util::FileHelper.safe_read("#{dir}#{file}", nil)
              next unless content =~ /interface.*#{interface_name}/

              dhcp = content.match(/dhcp-server-identifier ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/)
              return dhcp[1] if dhcp
            end
          end
          return unless File.readable?('/var/lib/NetworkManager/')

          search_internal_leases(interface_name)
        end

        def search_internal_leases(interface_name)
          files = Dir.entries('/var/lib/NetworkManager/').reject { |dir| dir =~ /^\.+$/ }
          lease_file = files.find { |file| file =~ /internal.*#{interface_name}\.lease/ }
          return unless lease_file

          dhcp = Facter::Util::FileHelper.safe_read("/var/lib/NetworkManager/#{lease_file}", nil)

          return unless dhcp

          dhcp = dhcp.match(/SERVER_ADDRESS=(.*)/)
          dhcp[1] if dhcp
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
