# frozen_string_literal: true

require 'ffi'
require_relative 'structs'
require_relative 'ffi'
module Facter
  module Resolvers
    module Aix
      module FfiHelper
        KINFO_GET_AVENRUN = 1
        KINFO_READ        = 8 << 8
        KINFO_RT          = 1 << 8
        KINFO_RT_IFLIST   = KINFO_RT | 3

        module Libc
          extend ::FFI::Library

          RTLD_LAZY   = 0x00000004
          RTLD_GLOBAL = 0x00010000
          RTLD_MEMBER = 0x00040000

          @ffi_lib_flags = RTLD_LAZY | RTLD_GLOBAL | RTLD_MEMBER
          ffi_lib 'libc.a(shr.o)'

          attach_function :getkerninfo, %i[int pointer pointer int], :int
          attach_function :inet_ntop, %i[int pointer pointer uint], :string
        end

        def self.read_load_averages
          averages = ::FFI::MemoryPointer.new(:long_long, 3)
          averages_size = ::FFI::MemoryPointer.new(:int, 1)
          averages_size.write_int(averages.size)

          return if Libc.getkerninfo(KINFO_READ | KINFO_GET_AVENRUN, averages, averages_size, 0).negative?

          averages.read_array_of_long_long(3).map { |x| (x / 65_536.0) }
        end

        def self.read_interfaces
          ksize = Libc.getkerninfo(KINFO_RT_IFLIST, nil, nil, 0)

          log.debug('getkerninfo call was unsuccessful') if ksize.zero?

          ksize_ptr = ::FFI::MemoryPointer.new(:int, ksize.size)
          ksize_ptr.write_int(ksize)

          result_ptr = ::FFI::MemoryPointer.new(:char, ksize)

          res = Libc.getkerninfo(KINFO_RT_IFLIST, result_ptr, ksize_ptr, 0)
          log.debug('getkerninfo call was unsuccessful') if res == -1

          cursor = 0

          interfaces = {}
          while cursor < ksize_ptr.read_int
            hdr = FFI::IfMsghdr.new(result_ptr + cursor)

            case hdr[:ifm_type]
            when FFI::RTM_IFINFO
              link_addr = FFI::SockaddrDl.new(hdr.to_ptr + hdr.size)

              interface_name = link_addr[:sdl_data].to_s[0, link_addr[:sdl_nlen]]
              interfaces[interface_name] ||= {}

            when FFI::RTM_NEWADDR
              addresses = {}
              addr_cursor = cursor + hdr.size
              FFI::RTAX_LIST.each do |key|
                xand = hdr[:ifm_addrs] & FFI::RTA_LIST[key]
                next unless xand != 0

                sockaddr = FFI::Sockaddr.new(result_ptr + addr_cursor)
                addresses[key] = sockaddr
                roundup_nr = roundup(sockaddr)
                addr_cursor += roundup_nr
              end

              family = FFI::AF_UNSPEC

              addresses.each do |_k, addr|
                if family != FFI::AF_UNSPEC &&
                   addr[:sa_family] != FFI::AF_UNSPEC &&
                   family != addr[:sa_family]
                  family = FFI::AF_MAX
                  break
                end
                family = addr[:sa_family]
              end

              if addresses[FFI::RTAX_NETMASK][:sa_len]
                addresses[FFI::RTAX_NETMASK][:sa_family] = family
                netmask = address_to_string(addresses[FFI::RTAX_NETMASK])
              end

              address = address_to_string(addresses[FFI::RTAX_IFA]) if addresses[FFI::RTAX_IFA][:sa_len]

              if addresses[FFI::RTAX_NETMASK][:sa_len] && addresses[FFI::RTAX_IFA][:sa_len]
                network = address_to_string(addresses[FFI::RTAX_IFA], addresses[FFI::RTAX_NETMASK])
              end

              bindings = family == FFI::AF_INET ? :bindings : :bindings6
              interfaces[interface_name][bindings] ||= []
              interfaces[interface_name][bindings] << {
                netmask: netmask.read_string,
                address: address.read_string,
                network: network.read_string
              }
            else
              log.debug("got an unknown RT_IFLIST message: #{hdr[:ifm_type]}")
            end

            cursor += hdr[:ifm_msglen]
          end

          interfaces
        end

        def self.roundup(sockaddr)
          if sockaddr[:sa_len].positive?
            1 + ((sockaddr[:sa_len] - 1) | (1.size - 1))
          else
            1.size
          end
        end

        def self.address_to_string(sockaddr, mask = nil)
          if sockaddr[:sa_family] == FFI::AF_INET
            in_addr_ip = FFI::SockaddrIn.new(sockaddr.to_ptr)

            if mask && sockaddr[:sa_family] == mask[:sa_family]
              in_addr_mask = FFI::SockaddrIn.new(mask.to_ptr)
              in_addr_ip[:sin_addr][:s_addr] &= in_addr_mask[:sin_addr][:s_addr]
            end

            buffer = ::FFI::MemoryPointer.new(:char, FFI::INET_ADDRSTRLEN)
            Libc.inet_ntop(FFI::AF_INET, in_addr_ip[:sin_addr].to_ptr, buffer, 16)

            buffer
          elsif sockaddr[:sa_family] == FFI::AF_INET6
            in_addr_ip = FFI::SockaddrIn6.new(sockaddr.to_ptr)
            if mask && sockaddr[:sa_family] == mask[:sa_family]
              in_addr_mask = FFI::SockaddrIn6.new(sockaddr.to_ptr)
              16.times do |i|
                in_addr_ip[:sin6_addr][:u6_addr8][i] &= in_addr_mask[:sin6_addr][:u6_addr8][i]
              end
            end

            buffer = ::FFI::MemoryPointer.new(:char, FFI::INET6_ADDRSTRLEN)
            Libc.inet_ntop(FFI::AF_INET6, in_addr_ip[:sin6_addr].to_ptr, buffer, 16)

            buffer
          end
        end

        def self.log
          @log ||= Log.new(self)
        end
      end
    end
  end
end
