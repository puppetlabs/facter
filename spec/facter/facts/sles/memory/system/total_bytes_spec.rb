# frozen_string_literal: true

describe Facter::Sles::MemorySystemTotalBytes do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.total_bytes', value: 6_242_643_968)
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:total).and_return(6_242_643_968)
      allow(Facter::ResolvedFact).to receive(:new)
        .with('memory.system.total_bytes', 6_242_643_968)
        .and_return(expected_fact)

      fact = Facter::Sles::MemorySystemTotalBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
