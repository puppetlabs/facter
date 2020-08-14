# frozen_string_literal: true

describe Facts::Windows::Networking::Primary do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Windows::Networking::Primary.new }

    let(:value) { 'Ethernet0' }

    before do
      allow(Facter::Resolvers::Windows::Networking).to receive(:resolve).with(:primary_interface).and_return(value)
    end

    it 'calls Facter::Windows::Resolvers::Fips' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Windows::Networking).to have_received(:resolve).with(:primary_interface)
    end

    it 'returns true if fips enabled' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'networking.primary', value: value)
    end
  end
end
