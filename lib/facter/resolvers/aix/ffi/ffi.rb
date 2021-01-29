# frozen_string_literal: true

module Facter
  module Resolvers
    module Aix
      module FFI
        RTM_IFINFO = 0xe
        RTM_NEWADDR = 0xc

        RTAX_DST = 0
        RTAX_GATEWAY = 1
        RTAX_NETMASK = 2
        RTAX_GENMASK = 3
        RTAX_IFP = 4
        RTAX_IFA = 5
        RTAX_AUTHOR = 6
        RTAX_BRD = 7
        RTAX_MAX = 8

        RTA_DST = 0x1
        RTA_GATEWAY = 0x2
        RTA_NETMASK = 0x4
        RTA_GENMASK = 0x8
        RTA_IFP = 0x10
        RTA_IFA = 0x20
        RTA_AUTHOR = 0x40
        RTA_BRD = 0x80
        RTA_DOWNSTREAM = 0x100

        AF_UNSPEC = 0
        AF_INET = 2
        AF_INET6 = 24
        AF_MAX = 30

        INET_ADDRSTRLEN = 16
        INET6_ADDRSTRLEN = 46

        RTAX_LIST = [
          RTAX_DST,
          RTAX_GATEWAY,
          RTAX_NETMASK,
          RTAX_GENMASK,
          RTAX_IFP,
          RTAX_IFA,
          RTAX_AUTHOR,
          RTAX_BRD
        ].freeze

        RTA_LIST = [
          RTA_DST,
          RTA_GATEWAY,
          RTA_NETMASK,
          RTA_GENMASK,
          RTA_IFP,
          RTA_IFA,
          RTA_AUTHOR,
          RTA_BRD,
          RTA_DOWNSTREAM
        ].freeze
      end
    end
  end
end
