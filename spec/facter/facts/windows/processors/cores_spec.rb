# frozen_string_literal: true

describe Facts::Windows::Processors::Cores do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = instance_double(Facter::ResolvedFact, name: 'processors.cores', value: 2)
      allow(Facter::Resolvers::Processors).to receive(:resolve).with(:cores_per_socket).and_return(2)
      allow(Facter::ResolvedFact).to receive(:new).with('processors.cores', 2).and_return(expected_fact)

      fact = Facts::Windows::Processors::Cores.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
