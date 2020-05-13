# frozen_string_literal: true

describe Facts::Linux::Networking::Network do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Network.new }

    let(:value) { '10.16.122.163' }
    let(:interfaces) { { 'eth0' => { network: value }, 'en1' => { ip6: 'fe80::99bf:da20:ad3:9bfe' } } }
    let(:primary) { 'eth0' }

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:interfaces).and_return(interfaces)
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:primary_interface).and_return(primary)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with interfaces' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:interfaces)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with primary_interface' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:primary_interface)
    end

    it 'returns network fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array)
        .and contain_exactly(an_object_having_attributes(name: 'networking.network', value: value),
                             an_object_having_attributes(name: 'network', value: value, type: :legacy))
    end
  end
end
