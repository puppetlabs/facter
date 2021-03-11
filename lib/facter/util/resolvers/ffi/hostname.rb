# frozen_string_literal: true

require 'ffi'

module Facter
  module Util
    module Resolvers
      module Ffi
        class AddrInfo < ::FFI::Struct
          layout  :ai_flags, :int,
                  :ai_family, :int,
                  :ai_socketype, :int,
                  :ai_protocol, :int,
                  :ai_addrlen, :uint,
                  :ai_addr, :pointer,
                  :ai_canonname, :string,
                  :ai_next, :pointer
        end

        module Hostname
          HOST_NAME_MAX = 64

          extend ::FFI::Library
          ffi_lib ::FFI::Library::LIBC

          attach_function :getaddrinfo, %i[string string pointer pointer], :int
          attach_function :gethostname, %i[pointer int], :int
          attach_function :freeaddrinfo, [:pointer], :void

          def self.getffihostname
            raw_hostname = ::FFI::MemoryPointer.new(:char, HOST_NAME_MAX)

            res = Hostname.gethostname(raw_hostname, HOST_NAME_MAX)
            return unless res.zero?

            raw_hostname.read_string
          end

          def self.getffiaddrinfo(hostname) # rubocop:disable  Metrics/AbcSize
            ret = FFI::MemoryPointer.new(:pointer)

            hints = Facter::Util::Resolvers::Ffi::AddrInfo.new
            hints[:ai_family] = Socket::AF_UNSPEC
            hints[:ai_socketype] = Socket::SOCK_STREAM
            hints[:ai_flags] = Socket::AI_CANONNAME

            res = Hostname.getaddrinfo(hostname, '', hints.to_ptr, ret)
            log = Log.new(self)
            log.debug("FFI Getaddrinfo finished with exit status: #{res}")
            log.debug("FFI Getaddrinfo returned an AddrInfo struct at address: #{ret}")
            return unless res.zero?

            return if ret == FFI::Pointer::NULL || ret.read_pointer == FFI::Pointer::NULL

            begin
              addr = Facter::Util::Resolvers::Ffi::AddrInfo.new(ret.read_pointer)
              name = addr[:ai_canonname]
              log.debug("FFI AddrInfo struct has the fqdn: #{name}")
              return if !name || hostname == name

              name
            ensure
              Hostname.freeaddrinfo(ret.read_pointer)
            end
          end
        end
      end
    end
  end
end
