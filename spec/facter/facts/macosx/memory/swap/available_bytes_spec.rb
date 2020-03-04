# frozen_string_literal: true

describe Facts::Macosx::Memory::Swap::AvailableBytes do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.available_bytes', value: 1024)

      allow(Facter::Resolvers::Macosx::SwapMemory).to receive(:resolve).with(:available_bytes).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.available_bytes', 1024).and_return(expected_fact)

      fact = Facts::Macosx::Memory::Swap::AvailableBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
