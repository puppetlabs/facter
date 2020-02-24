# frozen_string_literal: true

describe Facter::Sles::MemorySystemAvailableBytes do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.available_bytes', value: 4_900_515_840)
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve)
        .with(:memfree)
        .and_return(4_900_515_840)
      allow(Facter::ResolvedFact).to receive(:new)
        .with('memory.system.available_bytes', 4_900_515_840)
        .and_return(expected_fact)

      fact = Facter::Sles::MemorySystemAvailableBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
