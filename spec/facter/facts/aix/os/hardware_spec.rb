# frozen_string_literal: true

describe Facts::Aix::Os::Hardware do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'os.hardware', value: 'value')
      allow(Facter::Resolvers::Hardware).to receive(:resolve).with(:hardware).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('os.hardware', 'value').and_return(expected_fact)

      fact = Facts::Aix::Os::Hardware.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
