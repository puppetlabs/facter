# frozen_string_literal: true

module Facter
  module Util
    module Linux
      class SocketParser
        class << self
          def retrieve_interfaces(logger)
            require 'socket'
            @interfaces = {}
            @log = logger
            Socket.getifaddrs.each do |ifaddr|
              populate_interface_info(ifaddr)
            end

            @interfaces
          end

          private

          def populate_interface_info(ifaddr)
            interface_name = ifaddr.name
            @interfaces[interface_name] = {} if @interfaces[interface_name].nil?

            mac(ifaddr)
            ip_info_of(ifaddr)
          end

          def mac(ifaddr)
            return unless @interfaces[ifaddr.name][:mac].nil?

            mac = search_for_mac(ifaddr)
            @interfaces[ifaddr.name][:mac] = mac if mac
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
            content = Facter::Core::Execution.execute("ip link show #{interface_name}", logger: @log)
            content.match(/master (\S*) /)&.captures&.first
          end

          def mac_from(ifaddr)
            if Socket.const_defined? :PF_LINK
              ifaddr.addr&.getnameinfo&.first # sometimes it returns localhost or ip
            elsif Socket.const_defined? :PF_PACKET
              return if ifaddr.addr.nil?

              mac_from_sockaddr_of(ifaddr)
            end
          rescue StandardError => e
            @log.debug("Could not read mac for interface #{ifaddr.name}, got #{e}")
          end

          def mac_from_sockaddr_of(ifaddr)
            result = ifaddr.addr.inspect_sockaddr
            result&.match(/hwaddr=([\h:]+)/)&.captures&.first
          end

          def ip_info_of(ifaddr)
            return if ifaddr.addr.nil? || ifaddr.netmask.nil?

            add_binding(ifaddr.name, ifaddr)
          rescue StandardError => e
            @log.debug("Could not read binding data, got #{e}")
          end

          def add_binding(interface_name, ifaddr)
            ip, netmask, binding_key = binding_data(ifaddr)
            binding = Facter::Util::Resolvers::Networking.build_binding(ip, netmask)
            return if binding.nil?

            @interfaces[interface_name][binding_key] = [] if @interfaces[interface_name][binding_key].nil?
            @interfaces[interface_name][binding_key] << binding

            @log.debug("Adding to interface #{interface_name}, binding:\n#{binding}")
          end

          def binding_data(ifaddr)
            # ipv6 ips are retrieved as <ip>%<interface_name>
            ip = ifaddr.addr.ip_address.split('%').first
            netmask = ifaddr.netmask.ip_address
            binding_key = ifaddr.addr.ipv4? ? :bindings : :bindings6

            [ip, netmask, binding_key]
          end
        end
      end
    end
  end
end
