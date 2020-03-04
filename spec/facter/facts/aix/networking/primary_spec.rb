# frozen_string_literal: true

describe Facts::Aix::Networking::Primary do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::Networking::Primary.new }

    let(:value) { 'en0' }

    before do
      allow(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:primary).and_return(value)
    end

    it 'calls Facter::Resolvers::Networking' do
      expect(Facter::Resolvers::Aix::Networking).to receive(:resolve).with(:primary)
      fact.call_the_resolver
    end

    it 'returns primary interface name' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'networking.primary', value: value)
    end
  end
end
