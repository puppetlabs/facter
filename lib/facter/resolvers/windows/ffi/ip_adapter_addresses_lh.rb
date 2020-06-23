# frozen_string_literal: true

MAX_ADAPTER_ADDRESS_LENGTH = 8
MAX_DHCPV6_DUID_LENGTH = 130

class SockAddr < FFI::Struct
  layout(
    :sa_family, :ushort,
    :sa_data, [:uint8, 14]
  )
end

class SocketAddress < FFI::Struct
  layout(
    :lpSockaddr, :pointer,
    :iSockaddrLength, :int32
  )
end

module Enums
  extend FFI::Library

  IP_PREFIX_ORIGIN = enum(
    :IpPrefixOriginOther, 0,
    :IpPrefixOriginManual,
    :IpPrefixOriginWellKnown,
    :IpPrefixOriginDhcp,
    :IpPrefixOriginRouterAdvertisement,
    :IpPrefixOriginUnchanged
  )

  IP_SUFFIX_ORIGIN = enum(
    :NlsoOther, 0,
    :NlsoManual,
    :NlsoWellKnown,
    :NlsoDhcp,
    :NlsoLinkLayerAddress,
    :NlsoRandom,
    :IpSuffixOriginOther,
    :IpSuffixOriginManual,
    :IpSuffixOriginWellKnown,
    :IpSuffixOriginDhcp,
    :IpSuffixOriginLinkLayerAddress,
    :IpSuffixOriginRandom,
    :IpSuffixOriginUnchanged
  )

  IP_DAD_STATE = enum(
    :NldsInvalid, 0,
    :NldsTentative,
    :NldsDuplicate,
    :NldsDeprecated,
    :NldsPreferred,
    :IpDadStateInvalid,
    :IpDadStateTentative,
    :IpDadStateDuplicate,
    :IpDadStateDeprecated,
    :IpDadStatePreferred
  )

  IF_CONNECTION_TYPE = enum(
    :NET_IF_CONNECTION_DEDICATED, 1,
    :NET_IF_CONNECTION_PASSIVE,
    :NET_IF_CONNECTION_DEMAND,
    :NET_IF_CONNECTION_MAXIMUM
  )

  TUNNEL_TYPE = enum(
    :TUNNEL_TYPE_NONE, 0,
    :TUNNEL_TYPE_OTHER,
    :TUNNEL_TYPE_DIRECT,
    :TUNNEL_TYPE_6TO4,
    :TUNNEL_TYPE_ISATAP,
    :TUNNEL_TYPE_TEREDO,
    :TUNNEL_TYPE_IPHTTPS
  )
end

class IpAdapterUnicastAddressXPUnionStruct < FFI::Struct
  layout(
    :Length, :win32_ulong,
    :Flags, :dword
  )
end

class IpAdapterUnicastAddressXPUnion < FFI::Union
  layout(
    :Aligment, :ulong_long,
    :Struct, IpAdapterUnicastAddressXPUnionStruct
  )
end

class IpAdapterUnicastAddressLH < FFI::Struct
  layout(
    :Union, IpAdapterUnicastAddressXPUnion,
    :Next, :pointer,
    :Address, SocketAddress,
    :PrefixOrigin, Enums::IP_PREFIX_ORIGIN,
    :SuffixOrigin, Enums::IP_SUFFIX_ORIGIN,
    :DadState, Enums::IP_DAD_STATE,
    :ValidLifetime, :win32_ulong,
    :PreferredLifetime, :win32_ulong,
    :LeaseLifetime, :win32_ulong,
    :OnLinkPrefixLength, :uint8
  )
end

class AdapterAddressStruct < FFI::Struct
  layout(
    :Length, :win32_ulong,
    :IfIndex, :dword
  )
end

class AdapterAddressAligmentUnion < FFI::Union
  layout(
    :Aligment, :uint64,
    :Struct, AdapterAddressStruct
  )
end

class IpAdapterAddressesLh < FFI::Struct
  layout(
    :Union, AdapterAddressAligmentUnion,
    :Next, :pointer,
    :AdapterName, :pointer,
    :FirstUnicastAddress, :pointer,
    :FirstAnycastAddress, :pointer,
    :FirstMulticastAddress, :pointer,
    :FirstDnsServerAddress, :pointer,
    :DnsSuffix, :pointer,
    :Description, :pointer,
    :FriendlyName, :pointer,
    :PhysicalAddress, [:uchar, MAX_ADAPTER_ADDRESS_LENGTH],
    :PhysicalAddressLength, :win32_ulong,
    :Flags, :win32_ulong,
    :Mtu, :win32_ulong,
    :IfType, :dword,
    :OperStatus, :uint8,
    :Ipv6IfIndex, :dword,
    :ZoneIndices, [:win32_ulong, 16],
    :FirstPrefix, :pointer,
    :TransmitLinkSpeed, :ulong_long,
    :ReceiveLinkSpeed, :ulong_long,
    :FirstWinsServerAddress, :pointer,
    :FirstGatewayAddress, :pointer,
    :Ipv4Metric, :win32_ulong,
    :Ipv6Metric, :win32_ulong,
    :Luid, :ulong_long,
    :Dhcpv4Server, SocketAddress,
    :CompartmentId, :uint32, # https://github.com/tpn/winsdk-10/blob/master/Include/10.0.14393.0/shared/ifdef.h
    :NetworkGuid, [:uint8, 16], # https://docs.microsoft.com/en-us/windows/win32/api/guiddef/ns-guiddef-guid
    :ConnectionType, Enums::IF_CONNECTION_TYPE,
    :TunnelType, Enums::TUNNEL_TYPE,
    :Dhcpv6Server, SocketAddress,
    :Dhcpv6ClientDuid, [:uchar, MAX_DHCPV6_DUID_LENGTH],
    :Dhcpv6ClientDuidLength, :win32_ulong,
    :Dhcpv6Iaid, :win32_ulong,
    :FirstDnsSuffix, :pointer
  )
end
