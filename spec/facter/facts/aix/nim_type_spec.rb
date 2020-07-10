# frozen_string_literal: true

describe Facts::Aix::NimType do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Aix::NimType.new }

    let(:value) { 'standalone' }

    before do
      allow(Facter::Resolvers::Aix::Nim).to receive(:resolve).with(:type).and_return(value)
    end

    it 'calls Facter::Resolvers::Aix::Nim' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Aix::Nim).to have_received(:resolve).with(:type)
    end

    it 'returns nim_type fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'nim_type', value: value)
    end
  end
end
