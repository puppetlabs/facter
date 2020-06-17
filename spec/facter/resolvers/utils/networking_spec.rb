# frozen_string_literal: true

describe Resolvers::Utils::Networking do
  subject(:networking_helper) { Resolvers::Utils::Networking }

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

    context 'when input is ipv6 address' do
      let(:network) do
        IPAddr.new('fe80:0000:0000:0000:0000:0000:0000:0000/ffff:ffff:ffff:ffff:0000:0000:0000:0000').to_s
      end
      let(:netmask) do
        IPAddr.new('ffff:ffff:ffff:ffff:0000:0000:0000:0000/ffff:ffff:ffff:ffff:0000:0000:0000:0000').to_s
      end
      let(:addr) { 'fe80::dc20:a2b9:5253:9b46' }

      it 'returns ipv6 binding' do
        expect(networking_helper.build_binding(addr, 64)).to eql(address: addr, netmask: netmask, network: network)
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
end
