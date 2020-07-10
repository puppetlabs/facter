# frozen_string_literal: true

describe Facts::Windows::Processors::Models do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'processors.models', value: 'value')
      allow(Facter::Resolvers::Processors).to receive(:resolve).with(:models).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('processors.models', 'value').and_return(expected_fact)

      fact = Facts::Windows::Processors::Models.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
