# frozen_string_literal: true

describe 'Fedora ProcessorsModels' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'processors.models', value: 'value')
      allow(Facter::Resolvers::Linux::Processors).to receive(:resolve).with(:models).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('processors.models', 'value').and_return(expected_fact)

      fact = Facter::Fedora::ProcessorsModels.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
