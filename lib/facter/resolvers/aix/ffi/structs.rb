# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      module FFI
        class SockaddrDl < ::FFI::Struct
          layout :sdl_len, :uchar,
                 :sdl_family, :uchar,
                 :sdl_index, :ushort,
                 :sdl_type, :uchar,
                 :sdl_nlen, :uchar,
                 :sdl_alen, :uchar,
                 :sdl_slen, :uchar,
                 :sdl_data, [:char, 120]
        end

        class IfMsghdr < ::FFI::Struct
          layout :ifm_msglen, :ushort,
                 :ifm_version, :uchar,
                 :ifm_type, :uchar,
                 :ifm_addrs, :int,
                 :ifm_flags, :int,
                 :ifm_index, :ushort,
                 :ifm_addrlen, :uchar
        end

        class Sockaddr < ::FFI::Struct
          layout :sa_len, :uchar,
                 :sa_family, :uchar,
                 :sa_data, [:char, 14]
        end

        class InAddr < ::FFI::Struct
          layout :s_addr, :uint
        end

        class In6Addr < ::FFI::Struct
          layout :u6_addr8, [:uchar, 16]
        end

        class SockaddrIn < ::FFI::Struct
          layout :sin_len, :uchar,
                 :sin_family, :uchar,
                 :sin_port, :ushort,
                 :sin_addr, InAddr,
                 :sin_zero, [:uchar, 8]
        end

        class SockaddrIn6 < ::FFI::Struct
          layout :sin6_len, :uchar,
                 :sin6_family, :uchar,
                 :sin6_port, :ushort,
                 :sin6_flowinfo, :uint,
                 :sin6_addr, In6Addr,
                 :sin6_scope_id, :uint
        end

        class SockaddrStorage < ::FFI::Struct
          layout :ss_len, :uchar,
                 :ss_family, :uchar,
                 :ss_pad, [:char, 6],
                 :ss_align, :long_long,
                 :ss_pad2, [:char, 1264]
        end
      end
    end
  end
end
