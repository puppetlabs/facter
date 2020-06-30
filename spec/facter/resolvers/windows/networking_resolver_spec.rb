# frozen_string_literal: true

describe Facter::Resolvers::Networking do
  subject(:resolver) { Facter::Resolvers::Networking }

  describe '#resolve' do
    let(:logger) { instance_spy(Facter::Log) }
    let(:size_ptr) { instance_spy(FFI::MemoryPointer) }
    let(:adapter_address) { instance_spy(FFI::MemoryPointer) }

    before do
      allow(FFI::MemoryPointer).to receive(:new)
        .with(NetworkingFFI::BUFFER_LENGTH).and_return(size_ptr)
      allow(FFI::MemoryPointer).to receive(:new)
        .with(IpAdapterAddressesLh.size, NetworkingFFI::BUFFER_LENGTH)
        .and_return(adapter_address)
      allow(NetworkingFFI).to receive(:GetAdaptersAddresses)
        .with(NetworkingFFI::AF_UNSPEC, 14, FFI::Pointer::NULL, adapter_address, size_ptr)
        .and_return(error_code)

      resolver.instance_variable_set(:@log, logger)
    end

    after do
      resolver.invalidate_cache
    end

    context 'when fails to retrieve networking information' do
      let(:error_code) { NetworkingFFI::ERROR_NO_DATA }

      before do
        allow(logger).to receive(:debug).with('Unable to retrieve networking facts!')
      end

      it 'returns interfaces fact as nil' do
        expect(resolver.resolve(:interfaces)).to be(nil)
      end

      it 'logs debug message' do
        resolver.resolve(:interfaces)

        expect(logger).to have_received(:debug).with('Unable to retrieve networking facts!')
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
        expect(resolver.resolve(:interfaces)).to be(nil)
      end
    end

    context 'when it succeeded to retrieve networking information but all interface are down' do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) {  instance_double('FFI::MemoryPointer') }
      let(:next_adapter) { instance_spy(FFI::Pointer) }

      before do
        allow(IpAdapterAddressesLh).to receive(:read_list).with(adapter_address).and_yield(adapter)
        allow(IpAdapterAddressesLh).to receive(:new).with(next_adapter).and_return(adapter)
        allow(adapter).to receive(:[]).with(:OperStatus).and_return(NetworkingFFI::IF_OPER_STATUS_DOWN)
        allow(adapter).to receive(:[]).with(:Next).and_return(next_adapter)
        allow(adapter).to receive(:to_ptr).and_return(FFI::Pointer::NULL)
      end

      it 'returns nil' do
        expect(resolver.resolve(:interfaces)).to be(nil)
      end
    end

    context "when it succeeded to retrieve networking information but the interface hasn't got an address" do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) do
        OpenStruct.new(OperStatus: NetworkingFFI::IF_OPER_STATUS_UP, IfType: NetworkingFFI::IF_TYPE_ETHERNET_CSMACD,
                       DnsSuffix: dns_ptr, FriendlyName: friendly_name_ptr, Flags: 0, Mtu: 1500,
                       FirstUnicastAddress: ptr)
      end
      let(:dns_ptr) { instance_spy(FFI::Pointer) }
      let(:friendly_name_ptr) { instance_spy(FFI::Pointer) }
      let(:ptr) { instance_spy(FFI::Pointer) }
      let(:unicast) { OpenStruct.new(Address: ptr, Next: ptr, to_ptr: FFI::Pointer::NULL) }

      before do
        allow(IpAdapterAddressesLh).to receive(:read_list).with(adapter_address).and_yield(adapter)
        allow(IpAdapterUnicastAddressLH).to receive(:read_list).with(ptr).and_yield(unicast)
        allow(NetworkUtils).to receive(:address_to_string).with(ptr).and_return(nil)
        allow(IpAdapterUnicastAddressLH).to receive(:new).with(ptr).and_return(unicast)
        allow(NetworkUtils).to receive(:find_mac_address).with(adapter).and_return('00:50:56:9A:F8:6B')
        allow(friendly_name_ptr).to receive(:read_wide_string_without_length).and_return('Ethernet0')
        allow(dns_ptr).to receive(:read_wide_string_without_length).and_return('10.122.0.2')
      end

      it 'returns interfaces' do
        expected = {
          'Ethernet0' => {
            dhcp: nil,
            mac: '00:50:56:9A:F8:6B',
            mtu: 1500
          }
        }
        expect(resolver.resolve(:interfaces)).to eql(expected)
      end

      it 'returns nil for mtu fact as primary interface is nil' do
        expect(resolver.resolve(:mtu)).to be(nil)
      end

      it 'returns nil for dhcp fact as primary interface is nil' do
        expect(resolver.resolve(:dhcp)).to be(nil)
      end

      it 'returns nil for mac fact as primary interface is nil' do
        expect(resolver.resolve(:mac)).to be(nil)
      end
    end

    context 'when it succeeded to retrieve networking information but the interface has an address' do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) do
        OpenStruct.new(OperStatus: NetworkingFFI::IF_OPER_STATUS_UP, IfType: NetworkingFFI::IF_TYPE_ETHERNET_CSMACD,
                       DnsSuffix: dns_ptr, FriendlyName: friendly_name_ptr, Flags: 0, Mtu: 1500,
                       FirstUnicastAddress: ptr, Next: ptr, to_ptr: FFI::Pointer::NULL)
      end
      let(:ptr) { instance_spy(FFI::Pointer) }
      let(:dns_ptr) { instance_spy(FFI::Pointer) }
      let(:friendly_name_ptr) { instance_spy(FFI::Pointer) }
      let(:unicast) { OpenStruct.new(Address: address, Next: ptr, to_ptr: FFI::Pointer::NULL, OnLinkPrefixLength: 24) }
      let(:address) { OpenStruct.new(lpSockaddr: ptr) }
      let(:sock_address) { OpenStruct.new(sa_family: NetworkingFFI::AF_INET) }
      let(:binding) do
        {
          address: '10.16.127.3',
          netmask: '255.255.255.0',
          network: '10.16.127.0'
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
        allow(dns_ptr).to receive(:read_wide_string_without_length).and_return('10.122.0.2')
        allow(friendly_name_ptr).to receive(:read_wide_string_without_length).and_return('Ethernet0')
      end

      it 'returns interface' do
        result = {
          'Ethernet0' => {
            bindings: [binding],
            dhcp: nil,
            ip: '10.16.127.3',
            mac: '00:50:56:9A:F8:6B',
            mtu: 1500,
            netmask: '255.255.255.0',
            network: '10.16.127.0'
          }
        }
        expect(resolver.resolve(:interfaces)).to eql(result)
      end
    end

    context 'when it succeeded to retrieve networking information but the interface has an ipv6 address' do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) do
        OpenStruct.new(OperStatus: NetworkingFFI::IF_OPER_STATUS_UP, IfType: NetworkingFFI::IF_TYPE_ETHERNET_CSMACD,
                       DnsSuffix: dns_ptr, FriendlyName: friendly_name_ptr, Flags: 0, Mtu: 1500,
                       FirstUnicastAddress: ptr, Next: ptr, to_ptr: FFI::Pointer::NULL)
      end
      let(:ptr) { instance_spy(FFI::Pointer) }
      let(:dns_ptr) { instance_spy(FFI::Pointer) }
      let(:friendly_name_ptr) { instance_spy(FFI::Pointer) }
      let(:unicast) { OpenStruct.new(Address: address, Next: ptr, to_ptr: FFI::Pointer::NULL, OnLinkPrefixLength: 24) }
      let(:address) { OpenStruct.new(lpSockaddr: ptr) }
      let(:sock_address) { OpenStruct.new(sa_family: NetworkingFFI::AF_INET6) }
      let(:binding) do
        {
          address: 'fe80::7ca0:ab22:703a:b329',
          netmask: 'ffff:ff00::',
          network: 'fe80::'
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
        allow(dns_ptr).to receive(:read_wide_string_without_length).and_return('10.122.0.2')
        allow(friendly_name_ptr).to receive(:read_wide_string_without_length).and_return('Ethernet0')
      end

      it 'returns interface' do
        result = {
          'Ethernet0' => {
            bindings6: [binding],
            dhcp: nil,
            ip6: 'fe80::7ca0:ab22:703a:b329',
            mac: '00:50:56:9A:F8:6B',
            mtu: 1500,
            netmask6: 'ffff:ff00::',
            network6: 'fe80::',
            scope6: 'link'
          }
        }
        expect(resolver.resolve(:interfaces)).to eql(result)
      end
    end
  end
end
