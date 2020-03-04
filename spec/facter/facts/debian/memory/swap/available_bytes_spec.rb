# frozen_string_literal: true

describe Facts::Debian::Memory::Swap::AvailableBytes do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.available_bytes', value: 3072)
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_free).and_return(3072)
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.available_bytes', 3072).and_return(expected_fact)

      fact = Facts::Debian::Memory::Swap::AvailableBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
