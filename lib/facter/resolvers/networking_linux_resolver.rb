# frozen_string_literal: true

module Facter
  module Resolvers
    class NetworkingLinux < BaseResolver
      init_resolver

      DIRS = ['/var/lib/dhclient/', '/var/lib/dhcp/', '/var/lib/dhcp3/', '/var/lib/NetworkManager/', '/var/db/'].freeze

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_network_info(fact_name) }
        end

        def retrieve_network_info(fact_name)
          retrieve_interfaces
          retrieve_default_interface
          Facter::Util::Resolvers::Networking.expand_main_bindings(@fact_list)
          @fact_list[fact_name]
        end

        def retrieve_interfaces
          log.debug('retrieve interface info')
          output = Facter::Core::Execution.execute('ip a', logger: log)
          log.debug("'ip a' result is:\n#{output}")

          interfaces = {}
          interfaces_raw_data = split_raw_data_by_interfaces(output)

          interfaces_raw_data.each_with_index do |interface_raw_data, index|
            interface_name, interface_info = extract_interface_info_from(interface_raw_data)
            interfaces.merge!(interface_info)
            find_dhcp!(interface_name, index + 1, interfaces)
          end

          log.debug("interfaces = #{interfaces}")
          @fact_list[:interfaces] = interfaces
        end

        def split_raw_data_by_interfaces(output)
          arr = []
          output.each_line do |line|
            if line.start_with?(' ')
              arr[-1] << line.strip
            else
              arr << [line.strip]
            end
          end
          arr
        end

        def extract_interface_info_from(raw_data)
          # VLAN names are printed as <VLAN name>@<associated_interface>
          interface_name = raw_data[0].split(':')[1]&.split('@')&.first&.strip

          mtu = raw_data[0].match(/mtu (\d*)/)&.captures&.first&.to_i

          interfaces = {}
          interfaces[interface_name] = {}
          interfaces[interface_name][:mtu] = mtu if mtu

          get_mac_and_bindings(interface_name, interfaces, raw_data)
          [interface_name, interfaces]
        end

        def get_mac_and_bindings(interface_name, interfaces, raw_data)
          raw_data[1..-1].each do |line|
            if line.include?('inet6')
              add_binding(interfaces, line, interface_name, false)
            elsif line.include?('inet')
              add_binding(interfaces, line, interface_name, true)
            elsif line.include?('link/ether')
              interfaces[interface_name][:mac] = line.match(%r{link/ether ([\w:]+)})&.captures&.first&.to_s
            end
          end
        end

        def add_binding(interfaces, line, interface_name, ip_type_v4)
          ip_v4_regex = %r{[\d\.]+/\d+}
          ip_v6_regex = %r{[\w::]+/\d+}
          regex = ip_type_v4 == true ? ip_v4_regex : ip_v6_regex

          binding_key = ip_type_v4 == true ? :bindings : :bindings6

          construct_binding(binding_key, interface_name, interfaces, line, regex)
        end

        def construct_binding(binding_key, interface_name, interfaces, line, regex)
          interface_alias = line.match(/#{interface_name}.*/).to_s
          interface_alias = interface_name if interface_alias.empty?
          interfaces[interface_alias] = {} if interfaces[interface_alias].nil?

          ip, mask_length = line.match(regex).to_s.split('/')
          binding = Facter::Util::Resolvers::Networking.build_binding(ip, mask_length)
          return if binding.nil?

          insert_binding(binding, binding_key, interface_alias, interfaces)
          insert_binding(binding, binding_key, interface_name, interfaces) if interface_alias != interface_name
        end

        def insert_binding(binding, binding_key, interface_name, interfaces)
          interfaces[interface_name][binding_key] = [] if interfaces[interface_name][binding_key].nil?
          interfaces[interface_name][binding_key] << binding
        end

        def find_dhcp!(interface_name, index, interfaces)
          return if !interfaces[interface_name] || interfaces[interface_name][:dhcp]

          file_content = Facter::Util::FileHelper.safe_read("/run/systemd/netif/leases/#{index}", nil)
          dhcp = file_content.match(/SERVER_ADDRESS=(.*)/) if file_content
          if dhcp
            interfaces[interface_name][:dhcp] = dhcp[1]
          else
            alternate_dhcp = retrieve_from_other_directories(interface_name)
            interfaces[interface_name][:dhcp] = alternate_dhcp if alternate_dhcp
          end
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

        def retrieve_default_interface
          output = Facter::Core::Execution.execute('ip route get 1', logger: log)

          ip_route_tokens = output.each_line.first.strip.split(' ')
          default_interface = ip_route_tokens[4]

          @fact_list[:primary_interface] = default_interface
        end
      end
    end
  end
end
