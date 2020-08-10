# frozen_string_literal: true

describe Facts::Freebsd::Networking::Interfaces do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Freebsd::Networking::Interfaces.new }

    let(:interfaces) do
      {
        'awdl0' =>
          { mtu: 1484,
            mac: '2e:ba:e4:83:4b:b7',
            bindings6:
              [{ address: 'fe80::2cba:e4ff:fe83:4bb7',
                 netmask: 'ffff:ffff:ffff:ffff::',
                 network: 'fe80::' }],
            ip6: 'fe80::2cba:e4ff:fe83:4bb7',
            netmask6: 'ffff:ffff:ffff:ffff::',
            network6: 'fe80::' },
        'bridge0' => { mtu: 1500, mac: '82:17:0e:93:9d:00' },
        'en0' =>
          { dhcp: '192.587.6.9',
            mtu: 1500,
            mac: '64:5a:ed:ea:5c:81',
            bindings:
              [{ address: '192.168.1.2',
                 netmask: '255.255.255.0',
                 network: '192.168.1.0' }],
            ip: '192.168.1.2',
            netmask: '255.255.255.0',
            network: '192.168.1.0' },
        'gif0' => { mtu: 1280 },
        'lo0' =>
          { mtu: 16_384,
            bindings:
              [{ address: '127.0.0.1', netmask: '255.0.0.0', network: '127.0.0.0' }],
            bindings6:
              [{ address: '::1',
                 netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
                 network: '::1' },
               { address: 'fe80::1',
                 netmask: 'ffff:ffff:ffff:ffff::',
                 network: 'fe80::' }],
            ip: '127.0.0.1',
            netmask: '255.0.0.0',
            network: '127.0.0.0',
            ip6: '::1',
            netmask6: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
            network6: '::1' }
      }
    end

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:interfaces).and_return(interfaces)
    end

    it 'calls Facter::Resolvers::Networking with interfaces' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:interfaces)
    end

    it 'returns networking.interfaces fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.interfaces', value: anything)
    end

    it 'returns all interfaces' do
      interfaces = %w[awdl0 bridge0 en0 gif0 lo0]

      result = fact.call_the_resolver

      expect(result.value).to include(*interfaces)
    end

    it 'returns the interface awdl0 correctly' do
      expected = { 'mtu' => 1484,
                   'mac' => '2e:ba:e4:83:4b:b7',
                   'bindings6' =>
                       [{ 'address' => 'fe80::2cba:e4ff:fe83:4bb7',
                          'netmask' => 'ffff:ffff:ffff:ffff::',
                          'network' => 'fe80::' }],
                   'ip6' => 'fe80::2cba:e4ff:fe83:4bb7',
                   'netmask6' => 'ffff:ffff:ffff:ffff::',
                   'network6' => 'fe80::' }

      result = fact.call_the_resolver

      expect(result.value['awdl0']).to match(expected)
    end

    it 'returns the interface bridge0 correctly' do
      result = fact.call_the_resolver

      expect(result.value['bridge0']).to match({ 'mtu' => 1500, 'mac' => '82:17:0e:93:9d:00' })
    end

    it 'returns the interface en0 correctly' do
      expected = { 'mtu' => 1500,
                   'mac' => '64:5a:ed:ea:5c:81',
                   'bindings' =>
                       [{ 'address' => '192.168.1.2',
                          'netmask' => '255.255.255.0',
                          'network' => '192.168.1.0' }],
                   'ip' => '192.168.1.2',
                   'netmask' => '255.255.255.0',
                   'network' => '192.168.1.0',
                   'dhcp' => '192.587.6.9' }

      result = fact.call_the_resolver

      expect(result.value['en0']).to match(expected)
    end

    it 'returns the interface gif0 correctly' do
      result = fact.call_the_resolver

      expect(result.value['gif0']).to match({ 'mtu' => 1280 })
    end

    context 'when interfaces can not be retrieved' do
      let(:interfaces) { nil }

      it 'returns nil' do
        expect(fact.call_the_resolver)
          .to be_an_instance_of(Facter::ResolvedFact)
          .and have_attributes(name: 'networking.interfaces', value: interfaces)
      end
    end
  end
end
