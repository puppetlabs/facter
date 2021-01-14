# frozen_string_literal: true

module Facter
  module Util
    module Linux
      class Dhcp
        class << self
          DIRS = %w[/var/lib/dhclient/
                    /var/lib/dhcp/
                    /var/lib/dhcp3/
                    /var/lib/NetworkManager/
                    /var/db/].freeze

          def dhcp(interface_name, interface_index, logger)
            @log = logger
            @log.debug("Get DHCP for interface #{interface_name}")

            dhcp = search_systemd_netif_leases(interface_index)
            dhcp ||= search_dhclient_leases(interface_name)
            dhcp ||= search_internal_leases(interface_name)
            dhcp ||= search_with_dhcpcd_command(interface_name)
            dhcp
          end

          private

          def search_systemd_netif_leases(index)
            return if index.nil?

            file_content = Facter::Util::FileHelper.safe_read("/run/systemd/netif/leases/#{index}", nil)
            dhcp = file_content.match(/SERVER_ADDRESS=(.*)/) if file_content
            dhcp[1] if dhcp
          end

          def search_dhclient_leases(interface_name)
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

            nil
          end

          def search_internal_leases(interface_name)
            return unless File.readable?('/var/lib/NetworkManager/')

            files = Dir.entries('/var/lib/NetworkManager/').reject { |dir| dir =~ /^\.+$/ }
            lease_file = files.find { |file| file =~ /internal\.*#{interface_name}\.lease/ }
            return unless lease_file

            dhcp = Facter::Util::FileHelper.safe_read("/var/lib/NetworkManager/#{lease_file}", nil)

            return unless dhcp

            dhcp = dhcp.match(/SERVER_ADDRESS=(.*)/)
            dhcp[1] if dhcp
          end

          def search_with_dhcpcd_command(interface_name)
            output = Facter::Core::Execution.execute("dhcpcd -U #{interface_name}", logger: @log)
            dhcp = output.match(/dhcp_server_identifier='(.*)'/)
            dhcp[1] if dhcp
          end
        end
      end
    end
  end
end
