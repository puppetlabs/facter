# frozen_string_literal: true

describe Facter::Macosx::MemorySwapEncrypted do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.encrypted', value: true)

      allow(Facter::Resolvers::Macosx::SwapMemory).to receive(:resolve).with(:encrypted).and_return(true)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.encrypted', true).and_return(expected_fact)

      fact = Facter::Macosx::MemorySwapEncrypted.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
