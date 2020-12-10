# frozen_string_literal: true

require_relative 'ffi/ffi.rb'

module Facter
  module Resolvers
    module Solaris
      class Networking < BaseResolver
        init_resolver
        @log = Facter::Log.new(self)

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            begin
              lifreqs = load_interfaces
              @interfaces = {}

              lifreqs.each do |lifreq|
                obtain_info_for_interface(lifreq)
              end

              @fact_list = { interfaces: @interfaces } unless @interfaces.empty?
              @fact_list[:primary_interface] = Facter::Util::Resolvers::Networking::PrimaryInterface.read_from_route

              Facter::Util::Resolvers::Networking.expand_main_bindings(@fact_list)
            rescue StandardError => e
              @log.log_exception(e)
            end
            @fact_list[fact_name]
          end

          def obtain_info_for_interface(lifreq)
            @interfaces[lifreq.name] ||= {}

            add_mac(lifreq)
            add_bindings(lifreq)
            add_mtu(lifreq)
            @interfaces[lifreq.name][:dhcp] = Facter::Util::Resolvers::Networking::Dhcp.get(lifreq.name, @log)
          end

          def add_mac(lifreq)
            arp = FFI::Arpreq.new_for_ioctl(lifreq)

            ioctl = FFI::Ioctl.ioctl(FFI::SIOCGARP, arp, lifreq.ss_family)

            if ioctl == -1
              @log.debug("Could not read MAC address for interface #{lifreq.name} "\
                          "error code is: #{::FFI::LastError.error}")
            end

            mac = arp.sa_data_to_mac
            @interfaces[lifreq.name][:mac] ||= mac if mac.count('0') < 12
          end

          def add_bindings(lifreq)
            ip = inet_ntop(lifreq, lifreq.ss_family)
            _netmask, netmask_length = load_netmask(lifreq)

            bindings = Facter::Util::Resolvers::Networking.build_binding(ip, netmask_length)

            bindings_key = BINDINGS_KEY[lifreq.ss_family]
            @interfaces[lifreq.name][bindings_key] ||= []
            @interfaces[lifreq.name][bindings_key] << bindings
          end

          def add_mtu(lifreq)
            ioctl = FFI::Ioctl.ioctl(FFI::SIOCGLIFMTU, lifreq, lifreq.ss_family)

            if ioctl == -1
              @log.error("Cold not read MTU, error code is #{::FFI::LastError.error}")
              return
            end

            @interfaces[lifreq.name][:mtu] ||= lifreq[:lifr_lifru][:lifru_metric]
          end

          def load_netmask(lifreq)
            netmask_lifreq = FFI::Lifreq.new(lifreq.to_ptr)

            ioctl = FFI::Ioctl.ioctl(FFI::SIOCGLIFNETMASK, netmask_lifreq, lifreq.ss_family)

            if ioctl == -1
              @log.error("Could not read Netmask, error code is: #{::FFI::LastError.error}")
              return
            end

            netmask = inet_ntop(netmask_lifreq, lifreq.ss_family)
            [netmask, Facter::Util::Resolvers::Networking.calculate_mask_length(netmask)]
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

            @log.error("Could not read interface count, error code is: #{::FFI::LastError.error}") if ioctl == -1

            lifnum[:lifn_count]
          end

          def load_interfaces
            interface_count = count_interfaces

            lifconf = FFI::Lifconf.new_for_ioctl(interface_count)

            ioctl = FFI::Ioctl.ioctl(FFI::SIOCGLIFCONF, lifconf)

            # we need to enlarge the scope of this pointer so that Ruby GC will not free the memory.
            # If the pointer if freed, Lifreq structures will contain garbage from memory.
            @long_living_pointer = lifconf

            if ioctl == -1
              @log.error("Could not read interface information, error code is: #{::FFI::LastError.error}")
              return []
            end

            interfaces = []
            interface_count.times do |i|
              interfaces << FFI::Lifreq.new(lifconf[:lifc_buf] + (i * FFI::Lifreq.size))
            end

            interfaces
          end
        end
      end
    end
  end
end
