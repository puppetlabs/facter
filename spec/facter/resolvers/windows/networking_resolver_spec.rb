# frozen_string_literal: true

describe Facter::Resolvers::Networking do
  describe '#resolve' do
    let(:size_ptr) { double(FFI::MemoryPointer) }
    let(:adapter_address) { double(FFI::MemoryPointer) }

    before do
      allow(FFI::MemoryPointer).to receive(:new)
        .with(NetworkingFFI::BUFFER_LENGTH).and_return(size_ptr)
      allow(FFI::MemoryPointer).to receive(:new)
        .with(IpAdapterAddressesLh.size, NetworkingFFI::BUFFER_LENGTH)
        .and_return(adapter_address)
      allow(NetworkingFFI).to receive(:GetAdaptersAddresses)
        .with(NetworkingFFI::AF_UNSPEC, 14, FFI::Pointer::NULL, adapter_address, size_ptr)
        .and_return(error_code)
    end

    after do
      Facter::Resolvers::Networking.invalidate_cache
    end

    context 'when fails to retrieve networking information' do
      let(:error_code) { NetworkingFFI::ERROR_NO_DATA }

      it 'logs debug message and returns nil' do
        allow_any_instance_of(Facter::Log).to receive(:debug).with('Unable to retrieve networking facts!')
        expect(Facter::Resolvers::Networking.resolve(:interfaces)).to be(nil)
      end
    end

    context 'when fails to retrieve networking information after 3 tries' do
      let(:error_code) { NetworkingFFI::ERROR_BUFFER_OVERFLOW }

      before do
        allow(FFI::MemoryPointer).to receive(:new).exactly(4).times
                                                  .with(IpAdapterAddressesLh.size, NetworkingFFI::BUFFER_LENGTH)
                                                  .and_return(adapter_address)
        allow(NetworkingFFI)
          .to receive(:GetAdaptersAddresses)
          .exactly(3).times
          .with(NetworkingFFI::AF_UNSPEC, 14, FFI::Pointer::NULL, adapter_address, size_ptr)
          .and_return(error_code)
      end

      it 'returns nil' do
        expect(Facter::Resolvers::Networking.resolve(:interfaces)).to be(nil)
      end
    end

    context 'when it succeeded to retrieve networking information but all interface are down' do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) {  OpenStruct.new(OperStatus: NetworkingFFI::IF_OPER_STATUS_DOWN, Next: next_adapter) }
      let(:next_adapter) { double(FFI::Pointer) }

      before do
        allow(IpAdapterAddressesLh).to receive(:read_list).with(adapter_address).and_yield(adapter)
        allow(IpAdapterAddressesLh).to receive(:new).with(next_adapter).and_return(adapter)
        allow(adapter).to receive(:to_ptr).and_return(FFI::Pointer::NULL)
      end

      it 'returns nil' do
        expect(Facter::Resolvers::Networking.resolve(:interfaces)).to be(nil)
      end
    end

    context "when it succeeded to retrieve networking information but the interface hasn't got an address" do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) do
        OpenStruct.new(OperStatus: NetworkingFFI::IF_OPER_STATUS_UP, IfType: NetworkingFFI::IF_TYPE_ETHERNET_CSMACD,
                       DnsSuffix: dns_ptr, FriendlyName: friendly_name_ptr, Flags: 0, Mtu: 1500,
                       FirstUnicastAddress: ptr)
      end
      let(:dns_ptr) { double(FFI::Pointer, read_wide_string_without_length: '10.122.0.2') }
      let(:friendly_name_ptr) { double(FFI::Pointer, read_wide_string_without_length: 'Ethernet0') }
      let(:ptr) { double(FFI::Pointer) }
      let(:unicast) { OpenStruct.new(Address: ptr, Next: ptr, to_ptr: FFI::Pointer::NULL) }

      before do
        allow(IpAdapterAddressesLh).to receive(:read_list).with(adapter_address).and_yield(adapter)
        allow(IpAdapterUnicastAddressLH).to receive(:read_list).with(ptr).and_yield(unicast)
        allow(NetworkUtils).to receive(:address_to_string).with(ptr).and_return(nil)
        allow(IpAdapterUnicastAddressLH).to receive(:new).with(ptr).and_return(unicast)
        allow(NetworkUtils).to receive(:find_mac_address).with(adapter).and_return('00:50:56:9A:F8:6B')
      end

      it 'returns interfaces' do
        expect(Facter::Resolvers::Networking.resolve(:interfaces)).to eql(Ethernet0:
                                                                              {
                                                                                dhcp: nil,
                                                                                mac: '00:50:56:9A:F8:6B',
                                                                                mtu: 1500
                                                                              })
      end

      it 'returns nil for mtu and other networking facts as primary interface is nil' do
        expect(Facter::Resolvers::Networking.resolve(:mtu)).to be(nil)
        expect(Facter::Resolvers::Networking.resolve(:dhcp)).to be(nil)
        expect(Facter::Resolvers::Networking.resolve(:mac)).to be(nil)
      end
    end

    context 'when it succeeded to retrieve networking information but the interface has an address' do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) do
        OpenStruct.new(OperStatus: NetworkingFFI::IF_OPER_STATUS_UP, IfType: NetworkingFFI::IF_TYPE_ETHERNET_CSMACD,
                       DnsSuffix: dns_ptr, FriendlyName: friendly_name_ptr, Flags: 0, Mtu: 1500,
                       FirstUnicastAddress: ptr, Next: ptr, to_ptr: FFI::Pointer::NULL)
      end
      let(:ptr) { double(FFI::Pointer) }
      let(:dns_ptr) { double(FFI::Pointer, read_wide_string_without_length: '10.122.0.2') }
      let(:friendly_name_ptr) { double(FFI::Pointer, read_wide_string_without_length: 'Ethernet0') }
      let(:unicast) { OpenStruct.new(Address: address, Next: ptr, to_ptr: FFI::Pointer::NULL, OnLinkPrefixLength: 24) }
      let(:address) { OpenStruct.new(lpSockaddr: ptr) }
      let(:sock_address) { OpenStruct.new(sa_family: NetworkingFFI::AF_INET) }
      let(:binding) do
        {
          address: '10.16.127.3',
          netmask: IPAddr.new('255.255.255.0/255.255.255.0'),
          network: IPAddr.new('10.16.127.0/255.255.255.0')
        }
      end

      before do
        allow(IpAdapterAddressesLh).to receive(:read_list).with(adapter_address).and_yield(adapter)
        allow(IpAdapterUnicastAddressLH).to receive(:read_list).with(ptr).and_yield(unicast)
        allow(NetworkUtils).to receive(:address_to_string).with(address).and_return('10.16.127.3')
        allow(SockAddr).to receive(:new).with(ptr).and_return(sock_address)
        allow(NetworkUtils).to receive(:ignored_ip_address).with('10.16.127.3').and_return(false)
        allow(IpAdapterUnicastAddressLH).to receive(:new).with(ptr).and_return(unicast)
        allow(NetworkUtils).to receive(:find_mac_address).with(adapter).and_return('00:50:56:9A:F8:6B')
        allow(IpAdapterAddressesLh).to receive(:new).with(ptr).and_return(adapter)
      end

      it 'returns interface' do
        result = {
          Ethernet0: {
            bindings: [binding],
            dhcp: nil,
            ip: '10.16.127.3',
            mac: '00:50:56:9A:F8:6B',
            mtu: 1500,
            netmask: IPAddr.new('255.255.255.0/255.255.255.0'),
            network: IPAddr.new('10.16.127.0/255.255.255.0')
          }
        }
        expect(Facter::Resolvers::Networking.resolve(:interfaces)).to eql(result)
      end
    end

    context 'when it succeeded to retrieve networking information but the interface has an ipv6 address' do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) do
        OpenStruct.new(OperStatus: NetworkingFFI::IF_OPER_STATUS_UP, IfType: NetworkingFFI::IF_TYPE_ETHERNET_CSMACD,
                       DnsSuffix: dns_ptr, FriendlyName: friendly_name_ptr, Flags: 0, Mtu: 1500,
                       FirstUnicastAddress: ptr, Next: ptr, to_ptr: FFI::Pointer::NULL)
      end
      let(:ptr) { double(FFI::Pointer) }
      let(:dns_ptr) { double(FFI::Pointer, read_wide_string_without_length: '10.122.0.2') }
      let(:friendly_name_ptr) { double(FFI::Pointer, read_wide_string_without_length: 'Ethernet0') }
      let(:unicast) { OpenStruct.new(Address: address, Next: ptr, to_ptr: FFI::Pointer::NULL, OnLinkPrefixLength: 24) }
      let(:address) { OpenStruct.new(lpSockaddr: ptr) }
      let(:sock_address) { OpenStruct.new(sa_family: NetworkingFFI::AF_INET) }
      let(:binding) do
        {
          address: 'fe80::7ca0:ab22:703a:b329',
          netmask: IPAddr.new('ffff:ff00:0000:0000:0000:0000:0000:0000/ffff:ff00:0000:0000:0000:0000:0000:0000'),
          network: IPAddr.new('fe80:0000:0000:0000:0000:0000:0000:0000/ffff:ff00:0000:0000:0000:0000:0000:0000')
        }
      end

      before do
        allow(IpAdapterAddressesLh).to receive(:read_list).with(adapter_address).and_yield(adapter)
        allow(IpAdapterUnicastAddressLH).to receive(:read_list).with(ptr).and_yield(unicast)
        allow(NetworkUtils).to receive(:address_to_string).with(address).and_return('fe80::7ca0:ab22:703a:b329')
        allow(SockAddr).to receive(:new).with(ptr).and_return(sock_address)
        allow(NetworkUtils).to receive(:ignored_ip_address).with('fe80::7ca0:ab22:703a:b329')
        allow(IpAdapterUnicastAddressLH).to receive(:new).with(ptr).and_return(unicast)
        allow(NetworkUtils).to receive(:find_mac_address).with(adapter).and_return('00:50:56:9A:F8:6B')
        allow(IpAdapterAddressesLh).to receive(:new).with(ptr).and_return(adapter)
      end

      it 'returns interface' do
        result = {
          Ethernet0: {
            bindings6: [binding],
            dhcp: nil,
            ip6: 'fe80::7ca0:ab22:703a:b329',
            mac: '00:50:56:9A:F8:6B',
            mtu: 1500,
            netmask6: IPAddr.new('ffff:ff00:0000:0000:0000:0000:0000:0000/ffff:ff00:0000:0000:0000:0000:0000:0000'),
            network6: IPAddr.new('fe80:0000:0000:0000:0000:0000:0000:0000/ffff:ff00:0000:0000:0000:0000:0000:0000'),
            scope6: 'link'
          }
        }
        expect(Facter::Resolvers::Networking.resolve(:interfaces)).to eql(result)
      end
    end
  end
end
