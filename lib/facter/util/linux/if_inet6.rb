# frozen_string_literal: true

require 'ipaddr'

module Facter
  module Util
    module Linux
      class IfInet6
        class << self
          IFA_FLAGS = {
            'temporary' => 0x01,
            'noad' => 0x02,
            'optimistic' => 0x04,
            'dadfailed' => 0x08,
            'homeaddress' => 0x10,
            'deprecated' => 0x20,
            'tentative' => 0x40,
            'permanent' => 0x80
            # /proc/net/if_inet6 only supports the old 8bit flags
            # I have been unable to find a simple solution to accesses
            # the full 32bit flags.  netlink is all I can could find but
            # that will likely be ugly
            # 'managetempaddr' => 0x100,
            # 'noprefixroute' => 0x200,
            # 'mcautojoin' => 0x400,
            # 'stableprivacy' => 0x800
          }.freeze

          def read_flags
            return read_flags_from_proc if File.exist?('/proc/net/if_inet6')

            {}
          end

          private

          def read_flags_from_proc
            flags = init_flags
            Facter::Util::FileHelper.safe_read('/proc/net/if_inet6', nil).each_line do |line|
              iface = line.split
              next unless iface.size == 6

              ip = parse_ip(iface[0])
              flags[iface[5]][ip] = parse_ifa_flags(iface[4])
            end
            flags
          end

          def init_flags
            Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = [] } }
          end

          def parse_ifa_flags(flag)
            flag = flag.hex
            flags = []
            IFA_FLAGS.each_pair do |name, value|
              next if (flag & value).zero?

              flags << name
            end
            flags
          end

          def parse_ip(ip)
            # The ip address in if_net6 is a long string wit no colons
            ip = ip.scan(/(\h{4})/).join(':')
            IPAddr.new(ip).to_s
          end
        end
      end
    end
  end
end
