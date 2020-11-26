# frozen_string_literal: true

describe Facter::Util::Resolvers::Networking do
  subject(:networking_helper) { Facter::Util::Resolvers::Networking }

  let(:ipv4) { '192.168.1.3' }
  let(:ipv6) { 'fe80::1' }
  let(:mask4_length) { 10 }
  let(:mask6_length) { 57 }

  describe '#build_binding' do
    context 'when input is ipv4 address' do
      let(:netmask) { IPAddr.new('255.255.240.0/255.255.240.0').to_s }
      let(:network) { IPAddr.new('10.16.112.0/255.255.240.0').to_s }
      let(:addr) { '10.16.121.248' }

      it 'returns ipv4 binding' do
        expect(networking_helper.build_binding(addr, 20)).to eql(address: addr, netmask: netmask, network: network)
      end
    end

    context "when mask's length is nil" do
      it 'returns nil' do
        expect(networking_helper.build_binding(ipv4, nil)).to be(nil)
      end
    end

    context 'when input is ipv6 address' do
      let(:network) do
        IPAddr.new('fe80:0000:0000:0000:0000:0000:0000:0000/ffff:ffff:ffff:ffff:0000:0000:0000:0000').to_s
      end
      let(:netmask) do
        IPAddr.new('ffff:ffff:ffff:ffff:0000:0000:0000:0000/ffff:ffff:ffff:ffff:0000:0000:0000:0000').to_s
      end
      let(:addr) { 'fe80::dc20:a2b9:5253:9b46' }

      it 'returns ipv6 binding' do
        expect(networking_helper.build_binding(addr, 64)).to eql(address: addr, netmask: netmask, network: network,
                                                                 scope6: 'link')
      end
    end
  end

  describe '#get_scope' do
    context "when address's scope is link" do
      let(:address) { 'fe80::b13f:903e:5f5:3b52' }

      it 'returns scope6' do
        expect(networking_helper.get_scope(address)).to eql('link')
      end
    end

    context "when address's scope is global" do
      let(:address) { '::ffff:192.0.2.128' }

      it 'returns scope6' do
        expect(networking_helper.get_scope(address)).to eql('global')
      end
    end

    context "when address's scope is ipv4 compatible" do
      let(:address) { '::192.0.2.128' }

      it 'returns scope6' do
        expect(networking_helper.get_scope(address)).to eql('compat,global')
      end
    end

    context "when address's scope is site" do
      let(:address) { 'fec0::' }

      it 'returns scope6' do
        expect(networking_helper.get_scope(address)).to eql('site')
      end
    end
  end

  describe '#ignored_ip_address' do
    context 'when input is empty' do
      it 'returns true' do
        expect(networking_helper.ignored_ip_address('')).to be(true)
      end
    end

    context 'when input starts with 127.' do
      it 'returns true' do
        expect(networking_helper.ignored_ip_address('127.255.0.2')).to be(true)
      end
    end

    context 'when input is a valid ipv4 address' do
      it 'returns false' do
        expect(networking_helper.ignored_ip_address('169.255.0.2')).to be(false)
      end
    end

    context 'when input starts with fe80' do
      it 'returns true' do
        expect(networking_helper.ignored_ip_address('fe80::')).to be(true)
      end
    end

    context 'when input equal with ::1' do
      it 'returns true' do
        expect(networking_helper.ignored_ip_address('::1')).to be(true)
      end
    end

    context 'when input is a valid ipv6 address' do
      it 'returns false' do
        expect(networking_helper.ignored_ip_address('fe70::7d01:99a1:3900:531b')).to be(false)
      end
    end
  end

  describe '#expand_main_bindings' do
    let(:networking_facts) do
      {
        primary_interface: 'en0',
        interfaces:
           { 'alw0' => {
             mtu: 1484,
             mac: '2e:ba:e4:83:4b:b7',
             bindings6:
              [{ address: 'fe80::2cba:e4ff:fe83:4bb7',
                 netmask: 'ffff:ffff:ffff:ffff::',
                 network: 'fe80::' }]
           },
             'bridge0' => { mtu: 1500, mac: '82:17:0e:93:9d:00' },
             'en0' =>
           { mtu: 1500,
             mac: '64:5a:ed:ea:5c:81',
             bindings:
               [{ address: '192.168.1.2',
                  netmask: '255.255.255.0',
                  network: '192.168.1.0' }] },
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
                  network: 'fe80::' }] } }
      }
    end

    it 'expands the ipv4 binding' do
      expected = {
        mtu: 1500,
        mac: '64:5a:ed:ea:5c:81',
        bindings:
          [{ address: '192.168.1.2',
             netmask: '255.255.255.0',
             network: '192.168.1.0' }],
        ip: '192.168.1.2',
        netmask: '255.255.255.0',
        network: '192.168.1.0'
      }

      networking_helper.expand_main_bindings(networking_facts)

      expect(networking_facts[:interfaces]['en0']).to eq(expected)
    end

    it 'expands the ipv6 binding' do
      expected = {
        mtu: 1484,
        mac: '2e:ba:e4:83:4b:b7',
        bindings6:
          [{ address: 'fe80::2cba:e4ff:fe83:4bb7',
             netmask: 'ffff:ffff:ffff:ffff::',
             network: 'fe80::' }],
        ip6: 'fe80::2cba:e4ff:fe83:4bb7',
        netmask6: 'ffff:ffff:ffff:ffff::',
        network6: 'fe80::',
        scope6: 'link'
      }

      networking_helper.expand_main_bindings(networking_facts)

      expect(networking_facts[:interfaces]['alw0']).to eq(expected)
    end

    it 'expands both the ipv6 and ipv4 binding' do
      expected = {
        mtu: 16_384,
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
        ip6: '::1',
        netmask: '255.0.0.0',
        netmask6: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
        network: '127.0.0.0',
        network6: '::1',
        scope6: 'host'
      }

      networking_helper.expand_main_bindings(networking_facts)

      expect(networking_facts[:interfaces]['lo0']).to eq(expected)
    end

    it 'checks networking_facts have the expected keys' do
      expected = %i[mtu mac ip netmask network interfaces primary_interface]

      networking_helper.expand_main_bindings(networking_facts)

      expect(networking_facts.keys).to match_array(expected)
    end

    it 'exoands the primary interface' do
      expected = {
        mtu: 1500,
        mac: '64:5a:ed:ea:5c:81',
        ip: '192.168.1.2',
        netmask: '255.255.255.0',
        network: '192.168.1.0'
      }

      networking_helper.expand_main_bindings(networking_facts)

      expect(networking_facts).to include(expected)
    end

    context 'when there is a global ip address' do
      let(:networking_facts) do
        {
          interfaces:
            { 'lo0' =>
              { mtu: 16_384,
                bindings6:
                  [{ address: '::1',
                     netmask: 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff',
                     network: '::1' },
                   { address: 'fe87::1',
                     netmask: 'ffff:ffff:ffff:ffff::',
                     network: 'fe87::' }] } }
        }
      end

      it 'expands the correct binding' do
        expected = {
          ip6: 'fe87::1',
          netmask6: 'ffff:ffff:ffff:ffff::',
          network6: 'fe87::',
          scope6: 'link'
        }

        networking_helper.expand_main_bindings(networking_facts)

        expect(networking_facts[:interfaces]['lo0']).to include(expected)
      end
    end
  end

  describe '#calculate_mask_length' do
    context 'when ip v4' do
      let(:netmask) { '255.0.0.0' }

      it 'returns 8 as mask length' do
        mask_length = Facter::Util::Resolvers::Networking.calculate_mask_length(netmask)

        expect(mask_length).to be(8)
      end
    end

    context 'when ip v6' do
      let(:netmask) { '::ffff:ffff:ffff:ffff:ffff:ffff' }

      it 'returns 10 as mask length' do
        mask_length = Facter::Util::Resolvers::Networking.calculate_mask_length(netmask)

        expect(mask_length).to be(96)
      end
    end
  end
end
