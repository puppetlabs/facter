# frozen_string_literal: true

describe Facts::Debian::Memory::Swap::UsedBytes do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.used_bytes', value: 'value')
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_used_bytes).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.used_bytes', 'value').and_return(expected_fact)

      fact = Facts::Debian::Memory::Swap::UsedBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
