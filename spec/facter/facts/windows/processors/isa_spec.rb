# frozen_string_literal: true

describe 'Windows ProcessorsIsa' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'processors.isa', value: 'value')
      allow(Facter::Resolvers::Processors).to receive(:resolve).with(:isa).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('processors.isa', 'value').and_return(expected_fact)

      fact = Facter::Windows::ProcessorsIsa.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
