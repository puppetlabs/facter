# frozen_string_literal: true

require "#{ROOT_DIR}/lib/resolvers/windows/ffi/ffi"
require "#{ROOT_DIR}/lib/resolvers/windows/ffi/network_utils"
require "#{ROOT_DIR}/lib/resolvers/windows/ffi/ip_adapter_addresses_lh"

module NetworkingFFI
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib :iphlpapi
  attach_function :GetAdaptersAddresses, %i[uint32 uint32 pointer pointer pointer], :dword

  ffi_convention :stdcall
  ffi_lib :ws2_32
  attach_function :WSAAddressToStringW, %i[pointer dword pointer pointer pointer], :int32

  AF_UNSPEC = 0
  GAA_FLAG_SKIP_ANYCAST = 2
  GAA_FLAG_SKIP_MULTICAST = 4
  GAA_FLAG_SKIP_DNS_SERVER = 8
  BUFFER_LENGTH = 15_000
  ERROR_SUCCES = 0
  ERROR_BUFFER_OVERFLOW = 111
  ERROR_NO_DATA = 232
  IF_OPER_STATUS_UP = 1
  IF_OPER_STATUS_DOWN = 2
  IF_TYPE_ETHERNET_CSMACD = 6
  IF_TYPE_IEEE80211 = 71
  IP_ADAPTER_DHCP_ENABLED = 4
  INET6_ADDRSTRLEN = 46
  AF_INET = 2
  AF_INET6 = 23
end
