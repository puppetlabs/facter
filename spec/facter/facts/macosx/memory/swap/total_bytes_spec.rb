# frozen_string_literal: true

describe Facter::Macosx::MemorySwapTotalBytes do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.total_bytes', value: 1024)

      allow(Facter::Resolvers::Macosx::SwapMemory).to receive(:resolve).with(:total_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.total_bytes', 1024).and_return(expected_fact)

      fact = Facter::Macosx::MemorySwapTotalBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
