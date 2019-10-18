# frozen_string_literal: true

describe 'Windows Networking Resolver' do
  describe '#resolve' do
    let(:size_ptr) { double(FFI::MemoryPointer) }
    let(:adapter_address) { double(FFI::MemoryPointer) }
    before do
      allow(FFI::MemoryPointer).to receive(:new).with(NetworkingFFI::BUFFER_LENGTH).and_return(size_ptr)
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
        expect(Facter::Resolvers::Networking.resolve(:interfaces)).to eql(nil)
      end
    end

    context 'when fails to retrieve networking information after 3 tries' do
      let(:error_code) { NetworkingFFI::ERROR_BUFFER_OVERFLOW }
      before do
        allow(FFI::MemoryPointer).to receive(:new)
          .with(IpAdapterAddressesLh.size, NetworkingFFI::BUFFER_LENGTH)
          .and_return(adapter_address)
        allow(NetworkingFFI).to receive(:GetAdaptersAddresses)
          .with(NetworkingFFI::AF_UNSPEC, 14, FFI::Pointer::NULL, adapter_address, size_ptr)
          .and_return(error_code)
        allow(FFI::MemoryPointer).to receive(:new)
          .with(IpAdapterAddressesLh.size, NetworkingFFI::BUFFER_LENGTH)
          .and_return(adapter_address)
        allow(NetworkingFFI).to receive(:GetAdaptersAddresses)
          .with(NetworkingFFI::AF_UNSPEC, 14, FFI::Pointer::NULL, adapter_address, size_ptr)
          .and_return(error_code)
      end
      it 'returns nil' do
        expect(Facter::Resolvers::Networking.resolve(:interfaces)).to eql(nil)
      end
    end

    context 'when it succeeded to retrieve networking information but all interface are down' do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) { double(IpAdapterAddressesLh) }
      let(:next_adapter) { double(FFI::Pointer) }
      before do
        allow(IpAdapterAddressesLh).to receive(:read_list).with(adapter_address).and_yield(adapter)
        allow(adapter).to receive(:[]).with(:OperStatus).and_return(NetworkingFFI::IF_OPER_STATUS_DOWN)
        allow(adapter).to receive(:[]).with(:Next).and_return(next_adapter)
        allow(IpAdapterAddressesLh).to receive(:new).with(next_adapter).and_return(adapter)
        allow(adapter).to receive(:to_ptr).and_return(FFI::Pointer::NULL)
      end

      it 'returns nil' do
        expect(Facter::Resolvers::Networking.resolve(:interfaces)).to eql(nil)
      end
    end

    context "when it succeeded to retrieve networking information but the interface hasn't got an address" do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) { double(IpAdapterAddressesLh) }
      let(:ptr) { double(FFI::Pointer) }
      let(:unicast) { double(IpAdapterUnicastAddressLH) }
      before do
        # iterate list
        allow(IpAdapterAddressesLh).to receive(:read_list).with(adapter_address).and_yield(adapter)
        allow(adapter).to receive(:[]).with(:OperStatus).and_return(NetworkingFFI::IF_OPER_STATUS_UP)
        allow(adapter).to receive(:[]).with(:IfType).and_return(NetworkingFFI::IF_TYPE_ETHERNET_CSMACD)
        allow(adapter).to receive(:[]).with(:DnsSuffix).and_return(ptr)
        allow(ptr).to receive(:read_wide_string_without_length).and_return('10.122.0.2')
        allow(adapter).to receive(:[]).with(:FriendlyName).and_return(ptr)
        allow(ptr).to receive(:read_wide_string_without_length).and_return('Ethernet0')
        # build interface info
        allow(adapter).to receive(:[]).with(:Flags).and_return(0)
        allow(adapter).to receive(:[]).with(:Mtu).and_return(1500)
        allow(adapter).to receive(:[]).with(:FirstUnicastAddress).and_return(ptr)
        # find ip_addresses
        allow(IpAdapterUnicastAddressLH).to receive(:read_list).with(ptr).and_yield(unicast)
        allow(unicast).to receive(:[]).with(:Address).and_return(ptr)
        allow(NetworkUtils).to receive(:address_to_string).with(ptr).and_return(nil)
        allow(unicast).to receive(:[]).with(:Next).and_return(ptr)
        allow(IpAdapterUnicastAddressLH).to receive(:new).with(ptr).and_return(unicast)
        allow(unicast).to receive(:to_ptr).and_return(FFI::Pointer::NULL)
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
        expect(Facter::Resolvers::Networking.resolve(:mtu)).to eql(nil)
        expect(Facter::Resolvers::Networking.resolve(:dhcp)).to eql(nil)
        expect(Facter::Resolvers::Networking.resolve(:mac)).to eql(nil)
      end
    end

    context "when it succeeded to retrieve networking information but the interface hasn't got an address" do
      let(:error_code) { NetworkingFFI::ERROR_SUCCES }
      let(:adapter) { double(IpAdapterAddressesLh) }
      let(:ptr) { double(FFI::Pointer) }
      let(:unicast) { double(IpAdapterUnicastAddressLH) }
      let(:address) { double(SocketAddress) }
      let(:sock_address) { double(SockAddr) }
      let(:binding) do
        {
          address: '10.16.127.3',
          netmask: IPAddr.new('255.255.255.0/255.255.255.0'),
          network: IPAddr.new('10.16.127.0/255.255.255.0')
        }
      end
      before do
        # iterate list
        allow(IpAdapterAddressesLh).to receive(:read_list).with(adapter_address).and_yield(adapter)
        allow(adapter).to receive(:[]).with(:OperStatus).and_return(NetworkingFFI::IF_OPER_STATUS_UP)
        allow(adapter).to receive(:[]).with(:IfType).and_return(NetworkingFFI::IF_TYPE_ETHERNET_CSMACD)
        allow(adapter).to receive(:[]).with(:DnsSuffix).and_return(ptr)
        allow(ptr).to receive(:read_wide_string_without_length).and_return('10.122.0.2')
        allow(adapter).to receive(:[]).with(:FriendlyName).and_return(ptr)
        allow(ptr).to receive(:read_wide_string_without_length).and_return('Ethernet0')
        # build_interface_info
        allow(adapter).to receive(:[]).with(:Flags).and_return(0)
        allow(adapter).to receive(:[]).with(:Mtu).and_return(1500)
        allow(adapter).to receive(:[]).with(:FirstUnicastAddress).and_return(ptr)
        # find_ip_addresses
        allow(IpAdapterUnicastAddressLH).to receive(:read_list).with(ptr).and_yield(unicast)
        allow(unicast).to receive(:[]).with(:Address).and_return(address)
        allow(NetworkUtils).to receive(:address_to_string).with(address).and_return('10.16.127.3')
        allow(unicast).to receive(:[]).with(:Address).and_return(address)
        allow(address).to receive(:[]).with(:lpSockaddr).and_return(ptr)
        allow(SockAddr).to receive(:new).with(ptr).and_return(sock_address)
        # add_ip_data
        # find_bindings
        allow(sock_address).to receive(:[]).with(:sa_family).and_return(NetworkingFFI::AF_INET)
        allow(unicast).to receive(:[]).with(:OnLinkPrefixLength).and_return(24)
        # back to add_ip_data
        # back to find_ip_addresses
        # find_primary_interface
        allow(sock_address).to receive(:[]).with(:sa_family).and_return(NetworkingFFI::AF_INET)
        allow(NetworkUtils).to receive(:ignored_ip_address).with('10.16.127.3').and_return(false)
        allow(unicast).to receive(:[]).with(:Next).and_return(ptr)
        allow(IpAdapterUnicastAddressLH).to receive(:new).with(ptr).and_return(unicast)
        allow(unicast).to receive(:to_ptr).and_return(FFI::Pointer::NULL)
        # back to build_interface_info
        allow(NetworkUtils).to receive(:find_mac_address).with(adapter).and_return('00:50:56:9A:F8:6B')
        # back to iterate_list
        allow(adapter).to receive(:[]).with(:Next).and_return(ptr)
        allow(IpAdapterAddressesLh).to receive(:new).with(ptr).and_return(adapter)
        allow(adapter).to receive(:to_ptr).and_return(FFI::Pointer::NULL)
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
  end
end
