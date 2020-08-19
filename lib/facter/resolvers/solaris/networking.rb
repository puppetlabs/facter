# frozen_string_literal: true

require_relative 'ffi/ffi.rb'
require 'ipaddr'

module Facter
  module Resolvers
    module Solaris
      class Networking < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        @interfaces = {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            lifreqs = load_interfaces
            @interfaces = {}

            lifreqs.each do |lifreq|
              @interfaces[lifreq.name] ||= {}

              add_mac(lifreq)
              add_bindings(lifreq)
              add_mtu(lifreq)
              add_dhcp(lifreq.name)
            end

            @fact_list = { interfaces: @interfaces } unless @interfaces.empty?
            primary_interface

            ::Resolvers::Utils::Networking.expand_main_bindings(@fact_list)

            @fact_list[fact_name]
          end

          def add_mac(lifreq)
            arp = FFI::Arpreq.new_for_ioctl(lifreq)

            ioctl = FFI::Ioctl.ioctl(FFI::SIOCGARP, arp, lifreq.ss_family)

            @log.debug("Error! #{::FFI::LastError.error}") if ioctl == -1

            mac = arp.sa_data_to_mac
            @interfaces[lifreq.name][:mac] ||= mac if mac.count('0') < 12
          end

          def add_bindings(lifreq)
            ip = inet_ntop(lifreq, lifreq.ss_family)
            _netmask, netmask_length = load_netmask(lifreq)

            bindings = ::Resolvers::Utils::Networking.build_binding(ip, netmask_length)

            bindings_key = BINDINGS_KEY[lifreq.ss_family]
            @interfaces[lifreq.name][bindings_key] ||= []
            @interfaces[lifreq.name][bindings_key] << bindings
          end

          def add_mtu(lifreq)
            ioctl = FFI::Ioctl.ioctl(FFI::SIOCGLIFMTU, lifreq, lifreq.ss_family)

            @log.debug("Error! #{::FFI::LastError.error}") if ioctl == -1

            @interfaces[lifreq.name][:mtu] = lifreq[:lifr_lifru][:lifru_metric]
          end

          def load_netmask(lifreq)
            netmask_lifreq = FFI::Lifreq.new(lifreq.to_ptr)

            ioctl = FFI::Ioctl.ioctl(FFI::SIOCGLIFNETMASK, netmask_lifreq, lifreq.ss_family)

            if ioctl == -1
              @log.debug("Error! #{::FFI::LastError.error}")
            else
              netmask = inet_ntop(netmask_lifreq, lifreq.ss_family)
              [netmask, calculate_mask_length(netmask)]
            end
          end

          def inet_ntop(lifreq, ss_family)
            sockaddr = FFI::Sockaddr.new(lifreq.lifru_addr.to_ptr)
            sockaddr_in = FFI::SockaddrIn.new(sockaddr.to_ptr)
            ip = FFI::InAddr.new(sockaddr_in[:sin_addr].to_ptr)
            buffer_size = FFI::INET_ADDRSTRLEN
            buffer_size = FFI::INET6_ADDRSTRLEN if ss_family == FFI::AF_INET6
            buffer = ::FFI::MemoryPointer.new(:char, buffer_size)

            FFI::Ioctl.inet_ntop(ss_family, ip.to_ptr, buffer.to_ptr, buffer.size)
          end

          def count_interfaces
            lifnum = FFI::Lifnum.new
            lifnum[:lifn_family] = FFI::AF_UNSPEC
            lifnum[:lifn_flags] = 0
            lifnum[:lifn_count] = 0

            ioctl = FFI::Ioctl.ioctl(FFI::SIOCGLIFNUM, lifnum)

            @log.debug("Error! #{::FFI::LastError.error}") if ioctl == -1

            lifnum[:lifn_count]
          end

          def load_interfaces
            interface_count = count_interfaces

            lifconf = FFI::Lifconf.new_for_ioctl(interface_count)

            ioctl = FFI::Ioctl.ioctl(FFI::SIOCGLIFCONF, lifconf)

            @log.debug("Error! #{::FFI::LastError.error}") if ioctl == -1

            interfaces = []
            interface_count.times do |i|
              interfaces << FFI::Lifreq.new(lifconf[:lifc_buf] + (i * FFI::Lifreq.size))
            end

            interfaces
          end

          def calculate_mask_length(netmask)
            ipaddr = IPAddr.new(netmask)
            ipaddr.to_i.to_s(2).count('1')
          end

          def primary_interface
            result = Facter::Core::Execution.execute('route -n get default', logger: log)

            @fact_list[:primary_interface] = result.match(/interface: (.+)/)&.captures&.first
          end

          def add_dhcp(interface_name)
            dhcpinfo_command = Facter::Core::Execution.which('dhcpinfo') || '/sbin/dhcpinfo'
            result = Facter::Core::Execution.execute("#{dhcpinfo_command} -i #{interface_name} ServerID", logger: log)

            @interfaces[interface_name][:dhcp] = result.chomp
          end
        end
      end
    end
  end
end
