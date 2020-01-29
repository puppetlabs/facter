# frozen_string_literal: true

describe 'Aix NetworkingPrimary' do
  context '#call_the_resolver' do
    let(:value) { 'en0' }
    subject(:fact) { Facter::Aix::NetworkingPrimary.new }

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
