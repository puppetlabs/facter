# frozen_string_literal: true

describe 'NetworkUtils' do
  describe '#address_to_strig' do
    let(:addr) { double('SocketAddress') }
    let(:size) { double(FFI::MemoryPointer) }
    let(:buffer) { double(FFI::MemoryPointer) }
    let(:length) { 32 }

    before do
      allow(addr).to receive(:[]).with(:lpSockaddr).and_return(address)
      allow(FFI::MemoryPointer).to receive(:new).with(NetworkingFFI::INET6_ADDRSTRLEN + 1).and_return(size)
      allow(FFI::MemoryPointer).to receive(:new).with(:wchar, NetworkingFFI::INET6_ADDRSTRLEN + 1).and_return(buffer)
      allow(addr).to receive(:[]).with(:lpSockaddr).and_return(address)
      allow(addr).to receive(:[]).with(:iSockaddrLength).and_return(length)
      allow(NetworkingFFI).to receive(:WSAAddressToStringW)
        .with(address, length, FFI::Pointer::NULL, buffer, size).and_return(error)
      allow(NetworkUtils).to receive(:extract_address).with(buffer).and_return('10.123.0.2')
    end

    context 'when lpSockaddr is null' do
      let(:address) { FFI::Pointer::NULL }
      let(:error) { 0 }
      it 'returns nil' do
        expect(NetworkUtils.address_to_string(addr)).to eql(nil)
      end
    end

    context 'when error code is zero' do
      let(:address) { double(FFI::MemoryPointer) }
      let(:error) { 0 }
      before do
      end
      it 'returns an address' do
        expect(NetworkUtils.address_to_string(addr)).to eql('10.123.0.2')
      end
    end

    context 'when error code is not zero' do
      let(:address) { double(FFI::MemoryPointer) }
      let(:error) { 1 }
      it 'returns nil and logs debug message' do
        allow_any_instance_of(Facter::Log).to receive(:debug).with('address to string translation failed!')
        expect(NetworkUtils.address_to_string(addr)).to eql(nil)
      end
    end
  end

  describe '#ignored_ip_address' do
    context 'when input is empty' do
      it 'returns true' do
        expect(NetworkUtils.ignored_ip_address('')).to eql(true)
      end
    end

    context 'when input starts with 127.' do
      it 'returns true' do
        expect(NetworkUtils.ignored_ip_address('127.255.0.2')).to eql(true)
      end
    end

    context 'when input is a valid ipv4 address' do
      it 'returns false' do
        expect(NetworkUtils.ignored_ip_address('169.255.0.2')).to eql(false)
      end
    end

    context 'when input starts with fe80' do
      it 'returns true' do
        expect(NetworkUtils.ignored_ip_address('fe80::')).to eql(true)
      end
    end

    context 'when input equal with ::1' do
      it 'returns true' do
        expect(NetworkUtils.ignored_ip_address('::1')).to eql(true)
      end
    end

    context 'when input is a valid ipv6 address' do
      it 'returns false' do
        expect(NetworkUtils.ignored_ip_address('fe70::7d01:99a1:3900:531b')).to eql(false)
      end
    end
  end

  describe '#build_binding' do
    context 'when input is ipv4 address' do
      let(:netmask) { IPAddr.new('255.255.240.0/255.255.240.0') }
      let(:network) { IPAddr.new('10.16.112.0/255.255.240.0') }
      let(:addr) { '10.16.121.248' }
      it 'returns ipv4 binding' do
        expect(NetworkUtils.build_binding(addr, 20)).to eql(address: addr, netmask: netmask, network: network)
      end
    end

    context 'when input is ipv6 address' do
      let(:network) { IPAddr.new('fe80:0000:0000:0000:0000:0000:0000:0000/ffff:ffff:ffff:ffff:0000:0000:0000:0000') }
      let(:netmask) { IPAddr.new('ffff:ffff:ffff:ffff:0000:0000:0000:0000/ffff:ffff:ffff:ffff:0000:0000:0000:0000') }
      let(:addr) { 'fe80::dc20:a2b9:5253:9b46' }
      it 'returns ipv6 binding' do
        expect(NetworkUtils.build_binding(addr, 64)).to eql(address: addr, netmask: netmask, network: network)
      end
    end
  end

  describe '#extract_address' do
    context 'when address is ipv6' do
      let(:addr) { 'fe80::38bf:8f11:6227:9e6b%6' }
      let(:input) { double(FFI::Pointer) }
      before do
        allow(input).to receive(:read_wide_string_without_length).and_return(addr)
      end

      it 'returns address without interface' do
        expect(NetworkUtils.extract_address(input)).to eql('fe80::38bf:8f11:6227:9e6b')
      end
    end
  end

  describe '#find_mac_address' do
    context 'from a char array' do
      let(:adapter) do
        Ps = Struct.new(:PhysicalAddress, :PhysicalAddressLength)
        Ps.new([0, 80, 86, 154, 248, 107, 0, 0], 6)
      end
      it 'returns mac address' do
        expect(NetworkUtils.find_mac_address(adapter)).to eql('00:50:56:9A:F8:6B')
      end
    end
  end
end
