# frozen_string_literal: true

describe Facts::Windows::Networking::Dhcp do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Networking::Dhcp.new }

    let(:value) { '10.16.122.163' }

    before do
      allow(Facter::Resolvers::Networking).to receive(:resolve).with(:dhcp).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Networking).to have_received(:resolve).with(:dhcp)
    end

    it 'returns ipaddress fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.dhcp', value: value)
    end
  end
end
