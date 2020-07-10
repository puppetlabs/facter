# frozen_string_literal: true

describe NetworkUtils do
  describe '#address_to_strig' do
    let(:logger) { instance_spy(Facter::Log) }
    let(:addr) { instance_spy('SocketAddress') }
    let(:size) { instance_spy(FFI::MemoryPointer) }
    let(:buffer) { instance_spy(FFI::MemoryPointer) }
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

      NetworkUtils.instance_variable_set(:@log, logger)
    end

    context 'when lpSockaddr is null' do
      let(:address) { FFI::Pointer::NULL }
      let(:error) { 0 }

      it 'returns nil' do
        expect(NetworkUtils.address_to_string(addr)).to be(nil)
      end
    end

    context 'when error code is zero' do
      let(:address) { instance_spy(FFI::MemoryPointer) }
      let(:error) { 0 }

      it 'returns an address' do
        expect(NetworkUtils.address_to_string(addr)).to eql('10.123.0.2')
      end
    end

    context 'when error code is not zero' do
      let(:address) { instance_spy(FFI::MemoryPointer) }
      let(:error) { 1 }

      it 'returns nil and logs debug message' do
        allow(logger).to receive(:debug).with('address to string translation failed!')
        expect(NetworkUtils.address_to_string(addr)).to be(nil)
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
    context 'with a char array' do
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
