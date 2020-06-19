# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      module FFI
        module Ioctl
          extend ::FFI::Library
          ffi_lib ::FFI::Library::LIBC, '/usr/lib/libsocket.so'

          attach_function :ioctl_base, :ioctl, %i[int int pointer], :int
          attach_function :open_socket, :socket, %i[int int int], :int
          attach_function :close_socket, :shutdown, %i[int int], :int
          attach_function :inet_ntop, %i[int pointer pointer uint], :string

          def self.ioctl(call_const, pointer, address_family = AF_INET)
            fd = Ioctl.open_socket(address_family, SOCK_DGRAM, 0)
            result = ioctl_base(fd, call_const, pointer)
            Ioctl.close_socket(fd, 2)
            result
          end
        end
      end
    end
  end
end
