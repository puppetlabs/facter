# frozen_string_literal: true

describe Facts::Windows::Path do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'path', value: 'value')
      allow(Facter::Resolvers::Path).to receive(:resolve).with(:path).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('path', 'value').and_return(expected_fact)

      fact = Facts::Windows::Path.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
