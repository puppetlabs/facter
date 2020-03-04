# frozen_string_literal: true

describe Facts::Macosx::Memory::Swap::Capacity do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.capacity', value: 1024)

      allow(Facter::Resolvers::Macosx::SwapMemory).to receive(:resolve).with(:capacity).and_return(1024)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.capacity', 1024).and_return(expected_fact)

      fact = Facts::Macosx::Memory::Swap::Capacity.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
