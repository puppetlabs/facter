# frozen_string_literal: true

module Facter
  module Resolvers
    class NetworkingLinux < BaseResolver
      @semaphore = Mutex.new
      @fact_list = {}

      DIRS = ['/var/lib/dhclient/', '/var/lib/dhcp/', '/var/lib/dhcp3/', '/var/lib/NetworkManager/', '/var/db/'].freeze

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_network_info(fact_name) }

          @fact_list[fact_name]
        end

        def retrieve_network_info(fact_name)
          @fact_list ||= {}

          retrieve_interface_info
          retrieve_interfaces_mac_and_mtu
          retrieve_default_interface
          ::Resolvers::Utils::Networking.expand_main_bindings(@fact_list)
          @fact_list[fact_name]
        end

        def retrieve_interfaces_mac_and_mtu
          @fact_list[:interfaces].map do |name, info|
            macaddress = Util::FileHelper.safe_read("/sys/class/net/#{name}/address", nil)
            info[:mac] = macaddress.strip if macaddress && !macaddress.include?('00:00:00:00:00:00')
            mtu = Util::FileHelper.safe_read("/sys/class/net/#{name}/mtu", nil)
            info[:mtu] = mtu.strip.to_i if mtu
          end
        end

        def retrieve_interface_info
          log.debug('retrieve_interface_info')
          output = Facter::Core::Execution.execute('ip -o address', logger: log)
          log.debug("ip -o address result is:\n#{output}")

          interfaces = {}

          output.each_line do |ip_line|
            ip_tokens = ip_line.split(' ')

            log.debug("ip_tokens = #{ip_tokens}")
            log.debug("interfaces = #{interfaces}")
            fill_ip_v4_info!(ip_tokens, interfaces)
            fill_io_v6_info!(ip_tokens, interfaces)
            find_dhcp!(ip_tokens, interfaces)
          end

          @fact_list[:interfaces] = interfaces
        end

        def find_dhcp!(tokens, network_info)
          interface_name = tokens[1]
          return if !network_info[interface_name] || network_info[interface_name][:dhcp]

          index = tokens[0].delete(':')
          file_content = Util::FileHelper.safe_read("/run/systemd/netif/leases/#{index}", nil)
          dhcp = file_content.match(/SERVER_ADDRESS=(.*)/) if file_content
          if dhcp
            network_info[interface_name][:dhcp] = dhcp[1]
          else
            alternate_dhcp = retrieve_from_other_directories(interface_name)
            network_info[interface_name][:dhcp] = alternate_dhcp if alternate_dhcp
          end
        end

        def retrieve_from_other_directories(interface_name)
          DIRS.each do |dir|
            next unless File.readable?(dir)

            lease_files = Dir.entries(dir).select { |file| file =~ /dhclient.*\.lease/ }
            next if lease_files.empty?

            lease_files.select do |file|
              content = Util::FileHelper.safe_read("#{dir}#{file}", nil)
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

          dhcp = Util::FileHelper.safe_read("/var/lib/NetworkManager/#{lease_file}", nil)

          return unless dhcp

          dhcp = dhcp.match(/SERVER_ADDRESS=(.*)/)
          dhcp[1] if dhcp
        end

        def fill_ip_v4_info!(ip_tokens, network_info)
          log.debug('fill_ip_v4_info!')
          return unless ip_tokens[2].casecmp('inet').zero?

          interface_name, ip4_address, ip4_mask_length = retrieve_name_and_ip_info(ip_tokens)

          log.debug("interface_name = #{interface_name}\n" \
                      "ip4_address = #{ip4_address}\n" \
                      "ip4_mask_length = #{ip4_mask_length}")

          binding = ::Resolvers::Utils::Networking.build_binding(ip4_address, ip4_mask_length)
          build_network_info_structure!(network_info, interface_name, :bindings)

          network_info[interface_name][:bindings] << binding
        end

        def retrieve_name_and_ip_info(tokens)
          interface_name = tokens[1]
          ip_info = tokens[3].split('/')
          ip_address = ip_info[0]
          ip_mask_length = ip_info[1]

          [interface_name, ip_address, ip_mask_length]
        end

        def fill_io_v6_info!(ip_tokens, network_info)
          return unless ip_tokens[2].casecmp('inet6').zero?

          interface_name, ip6_address, ip6_mask_length = retrieve_name_and_ip_info(ip_tokens)

          binding = ::Resolvers::Utils::Networking.build_binding(ip6_address, ip6_mask_length)

          build_network_info_structure!(network_info, interface_name, :bindings6)

          network_info[interface_name][:scope6] ||= ip_tokens[5]
          network_info[interface_name][:bindings6] << binding
        end

        def retrieve_default_interface
          output = Facter::Core::Execution.execute('ip route get 1', logger: log)

          ip_route_tokens = output.each_line.first.strip.split(' ')
          default_interface = ip_route_tokens[4]

          @fact_list[:primary_interface] = default_interface
        end

        def build_network_info_structure!(network_info, interface_name, binding)
          network_info[interface_name] = {} unless network_info.dig(interface_name)
          network_info[interface_name][binding] = [] unless network_info.dig(interface_name, binding)
        end
      end
    end
  end
end
