# frozen_string_literal: true

describe Facts::Linux::DhcpServers do
  subject(:fact) { Facts::Linux::DhcpServers.new }

  before do
    allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:interfaces).and_return(interfaces)
    allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:primary_interface).and_return(primary)
  end

  describe '#call_the_resolver' do
    let(:value) { { 'system' => '10.16.122.163', 'eth0' => '10.16.122.163', 'en1' => '10.32.10.163' } }
    let(:interfaces) { { 'eth0' => { dhcp: '10.16.122.163' }, 'en1' => { dhcp: '10.32.10.163' } } }
    let(:primary) { 'eth0' }

    it 'calls Facter::Resolvers::NetworkingLinux with interfaces' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:interfaces)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with primary_interface' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:primary_interface)
    end

    it 'returns dhcp_servers' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dhcp_servers', value: value, type: :legacy)
    end
  end

  describe '#call_the_resolver when resolver returns nil' do
    let(:interfaces) { nil }
    let(:primary) { nil }

    it 'returns nil' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'dhcp_servers', value: nil, type: :legacy)
    end
  end
end
