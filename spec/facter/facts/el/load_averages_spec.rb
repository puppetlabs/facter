# frozen_string_literal: true

describe 'Fedora LoadAverages' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'load_averages', value: 'value')

      allow(Facter::Resolvers::Linux::LoadAverages).to receive(:resolve).with(:load_averages).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('load_averages', 'value').and_return(expected_fact)

      fact = Facter::El::LoadAverages.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
