# frozen_string_literal: true

describe Facter::Resolvers::Macosx::Networking do
  subject(:networking) { Facter::Resolvers::Macosx::Networking }

  let(:log_spy) { instance_spy(Facter::Log) }

  describe '#resolve' do
    before do
      networking.instance_variable_set(:@log, log_spy)
      allow(Facter::Core::Execution).to receive(:execute).with('route -n get default', logger: log_spy)
                                                         .and_return(primary)
      allow(Facter::Core::Execution).to receive(:execute).with('ifconfig -a', logger: log_spy).and_return(interfaces)
      allow(Facter::Core::Execution)
        .to receive(:execute).with('ipconfig getoption en0 server_identifier', logger: log_spy).and_return(dhcp)
    end

    after do
      networking.invalidate_cache
    end

    let(:interfaces) { load_fixture('ifconfig_mac').read }
    let(:dhcp) { '192.168.143.1 ' }
    let(:primary) { load_fixture('osx_route').read }

    it 'detects primary interface' do
      expect(networking.resolve(:primary_interface)).to eq('en0')
    end

    it 'detects the dhcp server ip' do
      expect(networking.resolve(:dhcp)).to eq('192.168.143.1')
    end

    it 'detects all interfaces' do
      expected = %w[lo0 gif0 stf0 en0 en1 en2 bridge0 p2p0 awdl0 llw0 utun0 utun1 utun2]
      expect(networking.resolve(:interfaces).keys).to match_array(expected)
    end

    it 'checks that interface lo0 has the expected keys' do
      expected = %i[mtu bindings6 bindings]
      expect(networking.resolve(:interfaces)['lo0'].keys).to match_array(expected)
    end

    it 'checks that interface lo0 has the expected mtu' do
      expect(networking.resolve(:interfaces)['lo0']).to include({ mtu: 16_384 })
    end

    it 'checks that interface lo0 has the expected bindings' do
      expected = { bindings: [{ address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }] }
      expect(networking.resolve(:interfaces)['lo0']).to include(expected)
    end

    it 'checks interface lo0 has the expected bindings6' do
      expected = { bindings6: [{ address: '::1', netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff', network: '::1' },
                               { address: 'fe80::1', netmask: 'ffff:ffff:ffff:ffff::', network: 'fe80::' }] }
      expect(networking.resolve(:interfaces)['lo0']).to include(expected)
    end

    it 'detects interface en1' do
      expected = { mtu: 1500, mac: '82:17:0e:93:9d:00' }
      expect(networking.resolve(:interfaces)['en1']).to eq(expected)
    end

    it 'detects interface gif0' do
      expected = { mtu: 1280 }
      expect(networking.resolve(:interfaces)['gif0']).to eq(expected)
    end

    it 'checks that interface en0 has the expected keys' do
      expected = %i[mtu mac bindings]
      expect(networking.resolve(:interfaces)['en0'].keys).to match_array(expected)
    end

    it 'checks that interface en0 has the expected mtu' do
      expected = { mtu: 1500 }
      expect(networking.resolve(:interfaces)['en0']).to include(expected)
    end

    it 'checks interface en0 has the expected mac' do
      expected = { mac: '64:5a:ed:ea:5c:81' }
      expect(networking.resolve(:interfaces)['en0']).to include(expected)
    end

    it 'checks that interface en0 has the expected bindings6' do
      expected = { bindings: [{ address: '192.168.143.212', netmask: '255.255.255.0', network: '192.168.143.0' }] }
      expect(networking.resolve(:interfaces)['en0']).to include(expected)
    end

    it 'checks interface bridge0' do
      expected = { mtu: 1500, mac: '82:17:0e:93:9d:00' }
      expect(networking.resolve(:interfaces)['bridge0']).to include(expected)
    end

    it 'checks interface utun2' do
      expected = { bindings: [{ address: '10.16.132.213', netmask: '255.255.254.0', network: '10.16.132.0' }] }
      expect(networking.resolve(:interfaces)['utun2']).to include(expected)
    end

    context 'when primary interface could not be retrieved' do
      let(:primary) { 'invalid output' }

      it 'returns primary interface as nil' do
        expect(networking.resolve(:primary_interface)).to be(nil)
      end
    end

    context 'when dhcp server ip could not be retrieved' do
      let(:dhcp) { 'invalid output' }

      it 'returns dhcp server ip as nil' do
        expect(networking.resolve(:dhcp)).to be(nil)
      end
    end

    context 'when interfaces could not be retrieved' do
      let(:interfaces) { +'invalid output' }

      it 'returns interfaces as nil' do
        expect(networking.resolve(:interfaces)).to be(nil)
      end
    end
  end
end
