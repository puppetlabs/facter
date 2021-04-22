# frozen_string_literal: true

describe Facts::Windows::Virtual do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = instance_double(Facter::ResolvedFact, name: 'virtual', value: 'value')
      allow(Facter::Resolvers::Windows::Virtualization).to receive(:resolve).with(:virtual).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('virtual', 'value').and_return(expected_fact)

      fact = Facts::Windows::Virtual.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
