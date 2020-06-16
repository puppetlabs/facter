# frozen_string_literal: true

describe Resolvers::Utils::Networking do
  subject(:networking_helper) { Resolvers::Utils::Networking }

  let(:ipv4) { '192.168.1.3' }
  let(:ipv6) { 'fe80::1' }
  let(:mask4_length) { 10 }
  let(:mask6_length) { 57 }

  describe '#build_binding' do
    it 'returns an ipv4 address' do
      expect(networking_helper.build_binding(ipv4, mask4_length)[:address]).to eq(ipv4)
    end

    it 'returns an ipv4 netmask' do
      expect(networking_helper.build_binding(ipv4, mask4_length)[:netmask]).to eq('255.192.0.0')
    end

    it 'returns an ipv4 network' do
      expect(networking_helper.build_binding(ipv4, mask4_length)[:network]).to eq('192.128.0.0')
    end

    it 'returns an ipv6 address' do
      expect(networking_helper.build_binding(ipv6, mask6_length)[:address]).to eq(ipv6)
    end

    it 'returns an ipv6 netmask' do
      expect(networking_helper.build_binding(ipv6, mask6_length)[:netmask]).to eq('ffff:ffff:ffff:ff80::')
    end

    it 'returns an ipv6 network' do
      expect(networking_helper.build_binding(ipv6, mask6_length)[:network]).to eq('fe80::')
    end
  end
end
