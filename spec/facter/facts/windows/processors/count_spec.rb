# frozen_string_literal: true

describe 'Windows ProcessorsCount' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'processors.count', value: 'value')
      allow(Facter::Resolvers::Processors).to receive(:resolve).with(:count).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('processors.count', 'value').and_return(expected_fact)

      fact = Facter::Windows::ProcessorsCount.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
