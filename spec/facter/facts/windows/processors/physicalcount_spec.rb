# frozen_string_literal: true

describe 'Windows ProcessorsPhysicalcount' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'processors.physicalcount', value: 'value')
      allow(Facter::Resolvers::Processors).to receive(:resolve).with(:physicalcount).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('processors.physicalcount', 'value').and_return(expected_fact)

      fact = Facter::Windows::ProcessorsPhysicalcount.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
