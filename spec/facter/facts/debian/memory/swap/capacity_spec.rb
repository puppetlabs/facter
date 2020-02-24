# frozen_string_literal: true

describe Facter::Debian::MemorySwapCapacity do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.capacity', value: 2048)
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_capacity).and_return(2048)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.capacity', 2048).and_return(expected_fact)

      fact = Facter::Debian::MemorySwapCapacity.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
