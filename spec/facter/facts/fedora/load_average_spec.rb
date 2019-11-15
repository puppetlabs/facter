# frozen_string_literal: true

describe 'Fedora LoadAverage' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'load_average', value: 'value')
      allow(Facter::Resolvers::Linux::LoadAverage).to receive(:resolve).with(:loadavrg).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('load_average', 'value').and_return(expected_fact)

      fact = Facter::Fedora::LoadAverage.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
