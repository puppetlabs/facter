# frozen_string_literal: true

describe Facts::Macosx::Networking::Dhcp do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Networking::Dhcp.new }

    let(:value) { '192.168.158.6' }

    before do
      allow(Facter::Resolvers::Macosx::Ipaddress).to receive(:resolve).with(:dhcp).and_return(value)
    end

    it 'calls Facter::Resolvers::Macosx::Ipaddress' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Macosx::Ipaddress).to have_received(:resolve).with(:dhcp)
    end

    it 'returns networking.dhcp fact' do
      expect(fact.call_the_resolver)
        .to be_an_instance_of(Facter::ResolvedFact).and have_attributes(name: 'networking.dhcp', value: value)
    end
  end
end
