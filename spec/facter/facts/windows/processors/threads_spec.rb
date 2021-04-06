# frozen_string_literal: true

describe Facts::Windows::Processors::Threads do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = instance_double(Facter::ResolvedFact, name: 'processors.threads', value: 2)
      allow(Facter::Resolvers::Processors).to receive(:resolve).with(:threads_per_core).and_return(2)
      allow(Facter::ResolvedFact).to receive(:new).with('processors.threads', 2).and_return(expected_fact)

      fact = Facts::Windows::Processors::Threads.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
