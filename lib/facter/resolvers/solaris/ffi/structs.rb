# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      module FFI
        class SockaddrStorage < ::FFI::Struct
          layout  :ss_family, :int16,
                  :pad, [:char, 254]
        end

        class Sockaddr < ::FFI::Struct
          layout  :sa_family, :sa_family_t,
                  :sa_data, [:uchar, 14]
        end

        class Lifnum < ::FFI::Struct
          layout  :lifn_family, :sa_family_t,
                  :lifn_flags, :int,
                  :lifn_count, :int
        end

        class Arpreq < ::FFI::Struct
          layout  :arp_pa, Sockaddr,
                  :arp_ha, Sockaddr,
                  :arp_flags, :int

          def sa_data_to_mac
            self[:arp_ha][:sa_data].entries[0, 6].map do |s|
              s.to_s(16).rjust(2, '0')
            end.join ':'
          end

          def self.new_for_ioctl(lifreq)
            arp = Arpreq.new
            arp_addr = SockaddrIn.new(arp[:arp_pa].to_ptr)
            arp_addr[:sin_addr][:s_addr] = SockaddrIn.new(lifreq.lifru_addr.to_ptr).s_addr

            arp
          end
        end

        class Lifru1 < ::FFI::Union
          layout  :lifru_addrlen, :int,
                  :lifru_ppa, :uint_t
        end

        class Lifru < ::FFI::Union
          layout  :lifru_addr, SockaddrStorage,
                  :lifru_dstaddr, SockaddrStorage,
                  :lifru_broadaddr, SockaddrStorage,
                  :lifru_token, SockaddrStorage,
                  :lifru_subnet, SockaddrStorage,
                  :lifru_flags, :uint64,
                  :lifru_metric, :int,
                  :pad, [:char, 80]
        end

        class Lifreq < ::FFI::Struct
          layout  :lifr_name, [:char, 32],
                  :lifr_lifru1, Lifru1,
                  :lifr_movetoindex, :int,
                  :lifr_lifru, Lifru,
                  :pad, [:char, 80]

          def name
            self[:lifr_name].to_s
          end

          def ss_family
            self[:lifr_lifru][:lifru_addr][:ss_family]
          end

          def lifru_addr
            self[:lifr_lifru][:lifru_addr]
          end
        end

        class Lifconf < ::FFI::Struct
          layout  :lifc_family, :uint,
                  :lifc_flags, :int,
                  :lifc_len, :int,
                  :lifc_buf, :pointer

          def self.new_for_ioctl(interface_count)
            lifconf = new
            lifconf[:lifc_family] = 0
            lifconf[:lifc_flags] = 0
            lifconf[:lifc_len] = interface_count * Lifreq.size
            lifconf[:lifc_buf] = ::FFI::MemoryPointer.new(Lifreq, interface_count)
            lifconf
          end
        end

        class Lifcu < ::FFI::Union
          layout  :lifcu_buf, :caddr_t,
                  :lifcu_req, Lifreq
        end

        class InAddr < ::FFI::Struct
          layout :s_addr, :uint32_t
        end

        class SockaddrIn < ::FFI::Struct
          layout  :sin_family, :sa_family_t,
                  :sin_port, :in_port_t,
                  :sin_addr, InAddr,
                  :sin_zero, [:char, 8]

          def s_addr
            self[:sin_addr][:s_addr]
          end
        end
      end
    end
  end
end
