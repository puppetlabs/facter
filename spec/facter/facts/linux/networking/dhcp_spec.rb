# frozen_string_literal: true

describe Facts::Linux::Networking::Dhcp do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Linux::Networking::Dhcp.new }

    let(:value) { '10.16.122.163' }

    before do
      allow(Facter::Resolvers::NetworkingLinux).to receive(:resolve).with(:dhcp).and_return(value)
    end

    it 'calls Facter::Resolvers::NetworkingLinux with dhcp' do
      fact.call_the_resolver
      expect(Facter::Resolvers::NetworkingLinux).to have_received(:resolve).with(:dhcp)
    end

    it 'returns dhcp fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact)
        .and have_attributes(name: 'networking.dhcp', value: value)
    end
  end
end
