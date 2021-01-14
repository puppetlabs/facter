# frozen_string_literal: true

module Facter
  module Resolvers
    module Linux
      class Networking < BaseResolver
        init_resolver

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { retrieve_network_info(fact_name) }

            @fact_list[fact_name]
          end

          def retrieve_network_info(fact_name)
            add_info_from_socket_reader
            add_info_from_routing_table
            retrieve_primary_interface
            Facter::Util::Resolvers::Networking.expand_main_bindings(@fact_list)
            @fact_list[fact_name]
          end

          def add_info_from_socket_reader
            @fact_list[:interfaces] = Facter::Util::Linux::SocketParser.retrieve_interfaces(log)
            mtu_and_indexes = interfaces_mtu_and_index

            @fact_list[:interfaces].keys.each do |interface_name|
              mtu(interface_name, mtu_and_indexes)
              dhcp(interface_name, mtu_and_indexes)

              @log.debug("Found interface #{interface_name} with #{@fact_list[:interfaces][interface_name]}")
            end
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

          def mtu(interface_name, mtu_and_indexes)
            mtu = mtu_and_indexes.dig(interface_name, :mtu)
            @fact_list[:interfaces][interface_name][:mtu] = mtu unless mtu.nil?
          end

          def dhcp(interface_name, mtu_and_indexes)
            dhcp = Facter::Util::Linux::Dhcp.dhcp(interface_name, mtu_and_indexes.dig(interface_name, :index), log)
            @fact_list[:interfaces][interface_name][:dhcp] = dhcp unless dhcp.nil?
          end

          def add_info_from_routing_table
            routes4, routes6 = Facter::Util::Linux::RoutingTable.read_routing_table(log)
            compare_ips(routes4, :bindings)
            compare_ips(routes6, :bindings6)
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
end
